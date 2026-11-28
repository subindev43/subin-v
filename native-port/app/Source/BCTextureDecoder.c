#include "BCTextureDecoder.h"
#include <stdlib.h>
#include <string.h>
#define BCDEC_STATIC
#define BCDEC_IMPLEMENTATION
#include "../Tools/bcdec/bcdec.h"
#include "BCTextureDecoderReference.inc"

static void decodeBlock(int format,const void *compressed,void *destination,int pitch){
  switch(format){
    case 1:bcdec_bc1(compressed,destination,pitch);break;
    case 2:bcdec_bc2(compressed,destination,pitch);break;
    case 3:bcdec_bc3(compressed,destination,pitch);break;
    case 4:bcdec_bc4(compressed,destination,pitch);break;
    case 5:bcdec_bc5(compressed,destination,pitch);break;
    case 7:bcdec_bc7(compressed,destination,pitch);break;
  }
}

void *PGDecodeBC(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t rowPitch,uint32_t rowsPerImage,const void *source,size_t sourceSize,size_t *decodedSize){
  if(decodedSize)*decodedSize=0;
  if(format<1||format>7||!width||!height||!depth||!source||!decodedSize)return NULL;
  size_t pixelBytes=format==4?1:format==5?2:format==6?8:4;
  const size_t limit=256*1024*1024;
  // Bound each multiplication before computing the complete output size.
  if(width>limit/pixelBytes)return NULL;
  size_t destinationPitch=(size_t)width*pixelBytes;
  if(height>limit/destinationPitch)return NULL;
  size_t destinationSlice=destinationPitch*height;
  if(depth>limit/destinationSlice)return NULL;
  size_t bytes=destinationSlice*depth;
  uint32_t blocksX=width/4+(width%4!=0),blocksY=height/4+(height%4!=0);
  size_t blockBytes=format==1||format==4?8:16;
  if(!rowPitch)rowPitch=blocksX*blockBytes;
  if(rowPitch<blocksX*blockBytes)return NULL;
  size_t rowEnd=(size_t)(blocksY-1)*rowPitch+blocksX*blockBytes;
  if(rowEnd>sourceSize)return NULL;
  size_t slicePitch=(size_t)rowPitch*(rowsPerImage?rowsPerImage:blocksY);
  // Preserve the original tightly packed depth fallback, without overflow.
  if(depth>1&&slicePitch>(sourceSize-rowEnd)/(depth-1))slicePitch=sourceSize/depth;
  if(depth>1&&slicePitch>(sourceSize-rowEnd)/(depth-1))return NULL;
  uint8_t *decoded=malloc(bytes);if(!decoded)return NULL;
  for(uint32_t z=0;z<depth;z++)for(uint32_t by=0;by<blocksY;by++)for(uint32_t bx=0;bx<blocksX;bx++){
    const uint8_t *compressed=(const uint8_t *)source+z*slicePitch+by*(size_t)rowPitch+bx*blockBytes;
    uint8_t *destination=decoded+z*destinationSlice+(size_t)by*4*destinationPitch+(size_t)bx*4*pixelBytes;
    uint32_t rows=height-by*4;if(rows>4)rows=4;
    uint32_t columns=width-bx*4;if(columns>4)columns=4;
    if(format!=6&&rows==4&&columns==4){
      // bcdec accepts the complete texture's byte pitch. Interior blocks can
      // write directly, avoiding a scratch block and four separate copies.
      decodeBlock(format,compressed,destination,(int)destinationPitch);
    }else{
      _Alignas(16) uint8_t block[128];
      if(format==6){uint16_t rgb[48];bcdec_bc6h_half(compressed,rgb,12,0);uint16_t *rgba=(uint16_t *)block;for(int p=0;p<16;p++){memcpy(rgba+p*4,rgb+p*3,6);rgba[p*4+3]=0x3c00;}}
      else decodeBlock(format,compressed,block,(int)(4*pixelBytes));
      for(uint32_t y=0;y<rows;y++)memcpy(destination+y*destinationPitch,block+y*4*pixelBytes,columns*pixelBytes);
    }
  }
  *decodedSize=bytes;return decoded;
}

/* ---- Fast block-size-matched BC -> ETC2/EAC transcoder (keeps VRAM 1:1 with native BC on A16 and older) ---- */
static const int etc1_mod_tbl[8][4] = {
  { 2,   8,  -2,   -8}, { 5,  17,  -5,  -17}, { 9,  29,  -9,  -29}, {13,  42, -13,  -42},
  {18,  60, -18,  -60}, {24,  80, -24,  -80}, {33, 106, -33, -106}, {47, 183, -47, -183}
};
static const int etc2_non_opaque_tbl[8][4] = {
  {0,   8, 0,   -8}, {0,  17, 0,  -17}, {0,  29, 0,  -29}, {0,  42, 0,  -42},
  {0,  60, 0,  -60}, {0,  80, 0,  -80}, {0, 106, 0, -106}, {0, 183, 0, -183}
};
static const int8_t eac_mod_t0[8]  = {-3, -6, -9, -15, 2, 5, 8, 14};
static const int8_t eac_mod_t13[8] = {-1, -2, -3, -10, 0, 1, 2,  9};
static const int etc2_dist_tbl[8]  = {3, 6, 11, 16, 23, 32, 41, 64};
static const uint8_t etc2_tmode_r0_byte[16] = {
  0x04,0x05,0x06,0x07,0x0c,0x0d,0x0e,0xeb,0x14,0x15,0xf2,0xf3,0x1c,0xf9,0xfa,0xfb
};

static inline uint8_t clamp_u8(int v){ return (uint8_t)(v<0?0:(v>255?255:v)); }

static void encode_eac_block(const uint8_t vals[16], uint8_t dst[8]){
  int mn=255, mx=0;
  for(int i=0;i<16;i++){ int v=vals[i]; if(v<mn)mn=v; if(v>mx)mx=v; }
  int span=mx-mn;
  if(span==0){
    dst[0]=(uint8_t)mn; dst[1]=(1<<4)|13;
    dst[2]=0x92; dst[3]=0x49; dst[4]=0x24; dst[5]=0x92; dst[6]=0x49; dst[7]=0x24;
    return;
  }
  int tbl, mult, base;
  const int8_t *mod;
  if(span<=5){
    tbl=13; mult=1; base=mx-2; if(base<0)base=0; if(base>255)base=255;
    mod=eac_mod_t13;
  }else{
    tbl=0; mult=(span+14)/29; if(mult<1)mult=1; if(mult>15)mult=15;
    base=(mn+mx+mult)>>1; if(base<0)base=0; if(base>255)base=255;
    mod=eac_mod_t0;
  }
  uint64_t packed=0;
  for(int y=0;y<4;y++){
    for(int x=0;x<4;x++){
      int v=vals[y*4+x], best_i=0, best_e=1<<30;
      for(int i=0;i<8;i++){
        int c=base+(int)mod[i]*mult;
        if(c<0)c=0; else if(c>255)c=255;
        int e=c-v; if(e<0)e=-e;
        if(e<best_e){ best_e=e; best_i=i; if(e==0)break; }
      }
      int bit=((3-y)+(3-x)*4)*3;
      packed|=((uint64_t)best_i<<bit);
    }
  }
  dst[0]=(uint8_t)base;
  dst[1]=(uint8_t)((mult<<4)|tbl);
  dst[2]=(uint8_t)(packed>>40); dst[3]=(uint8_t)(packed>>32);
  dst[4]=(uint8_t)(packed>>24); dst[5]=(uint8_t)(packed>>16);
  dst[6]=(uint8_t)(packed>>8);  dst[7]=(uint8_t)packed;
}

static uint32_t subblock_best_table(const uint8_t rgba[64], const int sub[8], const int base[3],
                                    int punch_non_opaque, int *out_tbl, uint8_t out_idx[8]){
  const int (*tbls)[4] = punch_non_opaque ? etc2_non_opaque_tbl : etc1_mod_tbl;
  uint32_t best_err=UINT32_MAX;
  int best_t=0;
  for(int t=0;t<8;t++){
    uint32_t err=0;
    uint8_t cur_idx[8];
    for(int k=0;k<8;k++){
      const uint8_t *p=rgba+sub[k]*4;
      if(punch_non_opaque && p[3]<128){ cur_idx[k]=2; continue; }
      uint32_t pe=UINT32_MAX; int pi=0;
      for(int i=0;i<4;i++){
        if(punch_non_opaque && i==2) continue;
        int m=tbls[t][i];
        int dr=clamp_u8(base[0]+m)-(int)p[0];
        int dg=clamp_u8(base[1]+m)-(int)p[1];
        int db=clamp_u8(base[2]+m)-(int)p[2];
        uint32_t e=(uint32_t)(dr*dr+dg*dg+db*db);
        if(e<pe){ pe=e; pi=i; }
      }
      err+=pe; cur_idx[k]=(uint8_t)pi;
      if(err>=best_err) break;
    }
    if(err<best_err){
      best_err=err; best_t=t;
      for(int k=0;k<8;k++) out_idx[k]=cur_idx[k];
    }
  }
  *out_tbl=best_t;
  return best_err;
}

static uint32_t encode_etc2_tmode(const uint8_t rgba[64], int punch, int opaque, uint8_t out[8]){
  int min_l=1024, max_l=-1, min_p=0, max_p=0, cnt=0;
  for(int i=0;i<16;i++){
    const uint8_t *p=rgba+i*4;
    if(punch && !opaque && p[3]<128) continue;
    int lum=p[0]*3+p[1]*6+p[2];
    if(lum<min_l){ min_l=lum; min_p=i; }
    if(lum>max_l){ max_l=lum; max_p=i; }
    cnt++;
  }
  if(!cnt){ memset(out,0,8); out[0]=0x04; return 0; }
  const uint8_t *p0=rgba+min_p*4, *p1=rgba+max_p*4;
  int r0=(p0[0]*15+127)/255, g0=(p0[1]*15+127)/255, b0=(p0[2]*15+127)/255;
  int r1=(p1[0]*15+127)/255, g1=(p1[1]*15+127)/255, b1=(p1[2]*15+127)/255;
  int c0[3]={(r0<<4)|r0, (g0<<4)|g0, (b0<<4)|b0};
  int c1[3]={(r1<<4)|r1, (g1<<4)|g1, (b1<<4)|b1};
  int non_op=(punch && !opaque);
  uint32_t best_err=UINT32_MAX;
  int best_d=0;
  uint8_t best_idx[16]={0};
  for(int di=0;di<8;di++){
    int d=etc2_dist_tbl[di];
    int pal[4][3]={
      {c0[0], c0[1], c0[2]},
      {clamp_u8(c1[0]+d), clamp_u8(c1[1]+d), clamp_u8(c1[2]+d)},
      {c1[0], c1[1], c1[2]},
      {clamp_u8(c1[0]-d), clamp_u8(c1[1]-d), clamp_u8(c1[2]-d)}
    };
    uint32_t err=0;
    uint8_t cur[16];
    for(int i=0;i<16;i++){
      const uint8_t *p=rgba+i*4;
      if(non_op && p[3]<128){ cur[i]=2; continue; }
      uint32_t pe=UINT32_MAX; int pi=0;
      for(int k=0;k<4;k++){
        if(non_op && k==2) continue;
        int dr=pal[k][0]-(int)p[0], dg=pal[k][1]-(int)p[1], db=pal[k][2]-(int)p[2];
        uint32_t e=(uint32_t)(dr*dr+dg*dg+db*db);
        if(e<pe){ pe=e; pi=k; }
      }
      err+=pe; cur[i]=(uint8_t)pi;
      if(err>=best_err) break;
    }
    if(err<best_err){
      best_err=err; best_d=di;
      memcpy(best_idx, cur, 16);
    }
  }
  out[0]=etc2_tmode_r0_byte[r0];
  out[1]=(uint8_t)((g0<<4)|b0);
  out[2]=(uint8_t)((r1<<4)|g1);
  out[3]=(uint8_t)((b1<<4)|((best_d>>1)<<2)|(opaque?2:0)|(best_d&1));
  uint32_t pix=0;
  for(int y=0;y<4;y++)for(int x=0;x<4;x++){
    uint8_t idx=best_idx[y*4+x];
    int bit=y+x*4;
    if(idx&1) pix|=1u<<bit;
    if(idx&2) pix|=1u<<(bit+16);
  }
  out[4]=(uint8_t)(pix>>24); out[5]=(uint8_t)(pix>>16); out[6]=(uint8_t)(pix>>8); out[7]=(uint8_t)pix;
  return best_err;
}

static void encode_etc2_rgb_block(const uint8_t rgba[64], int punch, uint8_t dst[8]){
  static const int subV[2][8]={{0,4,8,12,1,5,9,13},{2,6,10,14,3,7,11,15}};
  static const int subH[2][8]={{0,1,2,3,4,5,6,7},{8,9,10,11,12,13,14,15}};
  int opaque=1;
  if(punch){
    for(int i=0;i<16;i++) if(rgba[i*4+3]<128){ opaque=0; break; }
  }
  int spanV=0, spanH=0;
  for(int s=0;s<2;s++){
    int mn[3]={255,255,255}, mx[3]={0,0,0}, cnt=0;
    for(int k=0;k<8;k++){
      const uint8_t *p=rgba+subV[s][k]*4;
      if(punch && !opaque && p[3]<128) continue;
      cnt++;
      for(int c=0;c<3;c++){ if(p[c]<mn[c])mn[c]=p[c]; if(p[c]>mx[c])mx[c]=p[c]; }
    }
    if(cnt) spanV+=(mx[0]-mn[0])+(mx[1]-mn[1])+(mx[2]-mn[2]);
    mn[0]=mn[1]=mn[2]=255; mx[0]=mx[1]=mx[2]=0; cnt=0;
    for(int k=0;k<8;k++){
      const uint8_t *p=rgba+subH[s][k]*4;
      if(punch && !opaque && p[3]<128) continue;
      cnt++;
      for(int c=0;c<3;c++){ if(p[c]<mn[c])mn[c]=p[c]; if(p[c]>mx[c])mx[c]=p[c]; }
    }
    if(cnt) spanH+=(mx[0]-mn[0])+(mx[1]-mn[1])+(mx[2]-mn[2]);
  }
  int flip=(spanH<spanV)?1:0;
  const int (*sub)[8]=flip?subH:subV;
  int sum[2][3]={{0}}, cnt[2]={0};
  for(int s=0;s<2;s++)for(int k=0;k<8;k++){
    const uint8_t *p=rgba+sub[s][k]*4;
    if(punch && !opaque && p[3]<128) continue;
    sum[s][0]+=p[0]; sum[s][1]+=p[1]; sum[s][2]+=p[2]; cnt[s]++;
  }
  if(!cnt[0] && !cnt[1]){
    memset(dst, 0, 8);
    if(punch && !opaque){
      /* All pixels transparent black: diff opaque=0 + all idx=2 (pix_msb=0xffff, pix_lsb=0). */
      dst[4]=0xff; dst[5]=0xff;
    }else{
      dst[3]=0x02;
    }
    return;
  }
  if(!cnt[0]) for(int c=0;c<3;c++){ sum[0][c]=sum[1][c]; cnt[0]=cnt[1]; }
  if(!cnt[1]) for(int c=0;c<3;c++){ sum[1][c]=sum[0][c]; cnt[1]=cnt[0]; }
  int m0[3]={sum[0][0]/cnt[0], sum[0][1]/cnt[0], sum[0][2]/cnt[0]};
  int m1[3]={sum[1][0]/cnt[1], sum[1][1]/cnt[1], sum[1][2]/cnt[1]};
  int b0_5[3]={(m0[0]*31+127)/255, (m0[1]*31+127)/255, (m0[2]*31+127)/255};
  int b1_5[3]={(m1[0]*31+127)/255, (m1[1]*31+127)/255, (m1[2]*31+127)/255};
  int d[3]={b1_5[0]-b0_5[0], b1_5[1]-b0_5[1], b1_5[2]-b0_5[2]};
  int diff_fits=(d[0]>=-4 && d[0]<=3 && d[1]>=-4 && d[1]<=3 && d[2]>=-4 && d[2]<=3);
  if(diff_fits || punch){
    int dcl[3], base0[3], base1[3];
    for(int c=0;c<3;c++){
      dcl[c]=d[c]<-4?-4:(d[c]>3?3:d[c]);
      int b1c=b0_5[c]+dcl[c];
      base0[c]=(b0_5[c]<<3)|(b0_5[c]>>2);
      base1[c]=(b1c<<3)|(b1c>>2);
    }
    int cw0=0, cw1=0; uint8_t idx0[8], idx1[8];
    int non_op=(punch && !opaque);
    uint32_t err_diff=subblock_best_table(rgba, sub[0], base0, non_op, &cw0, idx0)
                     +subblock_best_table(rgba, sub[1], base1, non_op, &cw1, idx1);
    if(punch && !diff_fits){
      uint8_t t_blk[8];
      uint32_t err_t=encode_etc2_tmode(rgba, punch, opaque, t_blk);
      if(err_t<err_diff){ memcpy(dst, t_blk, 8); return; }
    }
    dst[0]=(uint8_t)((b0_5[0]<<3)|(dcl[0]&7));
    dst[1]=(uint8_t)((b0_5[1]<<3)|(dcl[1]&7));
    dst[2]=(uint8_t)((b0_5[2]<<3)|(dcl[2]&7));
    dst[3]=(uint8_t)((cw0<<5)|(cw1<<2)|((punch?opaque:1)<<1)|flip);
    uint32_t pix=0;
    for(int s=0;s<2;s++){
      const uint8_t *ix=s?idx1:idx0;
      for(int k=0;k<8;k++){
        int p=sub[s][k], x=p&3, y=p>>2, bit=y+x*4;
        if(ix[k]&1) pix|=1u<<bit;
        if(ix[k]&2) pix|=1u<<(bit+16);
      }
    }
    dst[4]=(uint8_t)(pix>>24); dst[5]=(uint8_t)(pix>>16); dst[6]=(uint8_t)(pix>>8); dst[7]=(uint8_t)pix;
    return;
  }
  /* Individual mode (!punch when deltas exceed [-4..3]) */
  int b0_4[3]={(m0[0]*15+127)/255, (m0[1]*15+127)/255, (m0[2]*15+127)/255};
  int b1_4[3]={(m1[0]*15+127)/255, (m1[1]*15+127)/255, (m1[2]*15+127)/255};
  int base0[3]={(b0_4[0]<<4)|b0_4[0], (b0_4[1]<<4)|b0_4[1], (b0_4[2]<<4)|b0_4[2]};
  int base1[3]={(b1_4[0]<<4)|b1_4[0], (b1_4[1]<<4)|b1_4[1], (b1_4[2]<<4)|b1_4[2]};
  int cw0=0, cw1=0; uint8_t idx0[8], idx1[8];
  subblock_best_table(rgba, sub[0], base0, 0, &cw0, idx0);
  subblock_best_table(rgba, sub[1], base1, 0, &cw1, idx1);
  dst[0]=(uint8_t)((b0_4[0]<<4)|b1_4[0]);
  dst[1]=(uint8_t)((b0_4[1]<<4)|b1_4[1]);
  dst[2]=(uint8_t)((b0_4[2]<<4)|b1_4[2]);
  dst[3]=(uint8_t)((cw0<<5)|(cw1<<2)|flip);
  uint32_t pix=0;
  for(int s=0;s<2;s++){
    const uint8_t *ix=s?idx1:idx0;
    for(int k=0;k<8;k++){
      int p=sub[s][k], x=p&3, y=p>>2, bit=y+x*4;
      if(ix[k]&1) pix|=1u<<bit;
      if(ix[k]&2) pix|=1u<<(bit+16);
    }
  }
  dst[4]=(uint8_t)(pix>>24); dst[5]=(uint8_t)(pix>>16); dst[6]=(uint8_t)(pix>>8); dst[7]=(uint8_t)pix;
}

size_t PGTranscodeBCtoETC2Size(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t *outBytesPerRow,uint32_t *outImageBytes){
  if(outBytesPerRow)*outBytesPerRow=0;
  if(outImageBytes)*outImageBytes=0;
  if(format<1||format>7||format==6||!width||!height||!depth)return 0;
  uint32_t bx=(width+3)/4, by=(height+3)/4;
  size_t bb=(format==1||format==4)?8:16;
  const size_t limit=256*1024*1024;
  if(bx>limit/bb)return 0;
  size_t bpr=(size_t)bx*bb;
  if(by>limit/bpr)return 0;
  size_t img=bpr*by;
  if(depth>limit/img)return 0;
  if(outBytesPerRow)*outBytesPerRow=(uint32_t)bpr;
  if(outImageBytes)*outImageBytes=(uint32_t)img;
  return img*depth;
}

int PGTranscodeBCtoETC2SliceRows(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t rowPitch,uint32_t rowsPerImage,const void *source,size_t sourceSize,void *destination,uint32_t zIndex,uint32_t byStart,uint32_t byEnd){
  if(format<1||format>7||format==6||!width||!height||!depth||!source||!destination||zIndex>=depth)return 0;
  uint32_t bx=width/4+(width%4!=0), by=height/4+(height%4!=0);
  if(byStart>=byEnd||byEnd>by)return 0;
  size_t bb=(format==1||format==4)?8:16;
  if(!rowPitch)rowPitch=(uint32_t)(bx*bb);
  if(rowPitch<bx*bb)return 0;
  size_t rowEnd=(size_t)(by-1)*rowPitch+bx*bb;
  if(rowEnd>sourceSize)return 0;
  size_t slicePitch=(size_t)rowPitch*(rowsPerImage?rowsPerImage:by);
  if(depth>1&&slicePitch>(sourceSize-rowEnd)/(depth-1))slicePitch=sourceSize/depth;
  if(depth>1&&slicePitch>(sourceSize-rowEnd)/(depth-1))return 0;
  size_t dstBpr=(size_t)bx*bb;
  size_t dstImg=dstBpr*by;
  const uint8_t *srcSlice=(const uint8_t *)source+(size_t)zIndex*slicePitch;
  uint8_t *dstSlice=(uint8_t *)destination+(size_t)zIndex*dstImg;
  for(uint32_t row=byStart;row<byEnd;row++){
    const uint8_t *srcRow=srcSlice+(size_t)row*rowPitch;
    uint8_t *dstRow=dstSlice+(size_t)row*dstBpr;
    for(uint32_t col=0;col<bx;col++){
      const uint8_t *in=srcRow+(size_t)col*bb;
      uint8_t *out=dstRow+(size_t)col*bb;
      if(format==1){
        uint8_t rgba[64];
        bcdec_bc1(in, rgba, 16);
        encode_etc2_rgb_block(rgba, 1, out);
      }else if(format==2||format==3||format==7){
        uint8_t rgba[64], alphas[16];
        decodeBlock(format, in, rgba, 16);
        for(int i=0;i<16;i++) alphas[i]=rgba[i*4+3];
        encode_eac_block(alphas, out);
        encode_etc2_rgb_block(rgba, 0, out+8);
      }else if(format==4){
        uint8_t r[16];
        bcdec_bc4(in, r, 4);
        encode_eac_block(r, out);
      }else{
        uint8_t rg[32], r[16], g[16];
        bcdec_bc5(in, rg, 8);
        for(int i=0;i<16;i++){ r[i]=rg[i*2]; g[i]=rg[i*2+1]; }
        encode_eac_block(r, out);
        encode_eac_block(g, out+8);
      }
    }
  }
  return 1;
}
