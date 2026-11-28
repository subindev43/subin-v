#pragma once
#include <stdint.h>
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
void *PGDecodeBC(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t rowPitch,uint32_t rowsPerImage,const void *source,size_t sourceSize,size_t *decodedSize);
// Original decoder used only by the explicit benchmark reference option.
void *PGDecodeBCReference(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t rowPitch,uint32_t rowsPerImage,const void *source,size_t sourceSize,size_t *decodedSize);
// Real-time block-size-matched transcoding (BC1->ETC2_RGB8A1, BC2/3/7->EAC_RGBA8, BC4->EAC_R11, BC5->EAC_RG11).
size_t PGTranscodeBCtoETC2Size(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t *outBytesPerRow,uint32_t *outImageBytes);
int PGTranscodeBCtoETC2SliceRows(int format,uint32_t width,uint32_t height,uint32_t depth,uint32_t rowPitch,uint32_t rowsPerImage,const void *source,size_t sourceSize,void *destination,uint32_t zIndex,uint32_t byStart,uint32_t byEnd);
#ifdef __cplusplus
}
#endif
