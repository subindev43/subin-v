import SwiftUI
import UIKit

struct CheatItem: Identifiable {
    let id = UUID()
    let code: String
    let name: String
    let desc: String
    let category: String
}

let CHEAT_LIST: [CheatItem] = [
    // MARK: - Nhân vật (12)
    CheatItem(code: "UNFREEZE", name: "Gỡ kẹt cảnh / Thoát Cutscene", desc: "Buộc thoát cutscene, mở khóa điều khiển và gỡ treo màn hình", category: "Nhân vật"),
    CheatItem(code: "PAINKILLER", name: "Bất tử 5 phút", desc: "Không nhận sát thương trong 5 phút", category: "Nhân vật"),
    CheatItem(code: "TURTLE", name: "Đầy Máu & Giáp", desc: "Hồi phục 100% máu, giáp và sửa xe", category: "Nhân vật"),
    CheatItem(code: "TOOLUP", name: "Tất cả Vũ khí", desc: "Nhận full tất cả vũ khí và đạn", category: "Nhân vật"),
    CheatItem(code: "LAWYERUP", name: "Xóa sao cảnh sát", desc: "Giảm mức độ truy nã về 0", category: "Nhân vật"),
    CheatItem(code: "FUGITIVE", name: "Tăng 1 sao cảnh sát", desc: "Tăng thêm 1 cấp độ truy nã", category: "Nhân vật"),
    CheatItem(code: "POWERUP", name: "Đầy kỹ năng", desc: "Nạp đầy thanh kỹ năng nhân vật", category: "Nhân vật"),
    CheatItem(code: "CATCHME", name: "Chạy siêu nhanh", desc: "Tăng tốc độ di chuyển tối đa", category: "Nhân vật"),
    CheatItem(code: "GOTGILLS", name: "Bơi siêu nhanh", desc: "Tăng tốc độ bơi dưới nước", category: "Nhân vật"),
    CheatItem(code: "HOPTOIT", name: "Siêu nhảy", desc: "Nhảy cao gấp 10 lần bình thường", category: "Nhân vật"),
    CheatItem(code: "SKYDIVE", name: "Trang bị Dù nhảy", desc: "Nhận dù để nhảy từ trên cao", category: "Nhân vật"),
    CheatItem(code: "LIQUOR", name: "Chế độ say rượu", desc: "Đi đứng lảo đảo hiệu ứng say xỉn", category: "Nhân vật"),

    // MARK: - Phương tiện (13)
    CheatItem(code: "BUZZOFF", name: "Trực thăng Buzzard", desc: "Trực thăng chiến đấu có súng & tên lửa", category: "Phương tiện"),
    CheatItem(code: "COMET", name: "Xe thể thao Comet", desc: "Xe Porsche 2 cửa siêu tốc", category: "Phương tiện"),
    CheatItem(code: "RAPIDGT", name: "Xe đua Rapid GT", desc: "Xe thể thao cao cấp", category: "Phương tiện"),
    CheatItem(code: "ROCKET", name: "Mô tô đua PCJ-600", desc: "Xe máy phân khối lớn tốc độ cao", category: "Phương tiện"),
    CheatItem(code: "OFFROAD", name: "Xe cào cào Sanchez", desc: "Mô tô địa hình vượt đồi núi", category: "Phương tiện"),
    CheatItem(code: "BANDIT", name: "Xe đạp BMX", desc: "Xe đạp biểu diễn nhào lộn", category: "Phương tiện"),
    CheatItem(code: "BARNSTORM", name: "Máy bay Stunt Plane", desc: "Máy bay nhào lộn cánh quạt", category: "Phương tiện"),
    CheatItem(code: "VINEWOOD", name: "Xe Limousine", desc: "Xe sang trọng kéo dài", category: "Phương tiện"),
    CheatItem(code: "TRASHED", name: "Xe rác Trashmaster", desc: "Xe chở rác bọc thép húc xe khác", category: "Phương tiện"),
    CheatItem(code: "DEATHCAR", name: "Xe bọc thép Duke O'Death", desc: "Xe cơ bắp chống đạn chống nổ cực mạnh", category: "Phương tiện"),
    CheatItem(code: "BUBBLES", name: "Tàu ngầm Kraken", desc: "Tàu lặn khám phá đáy đại dương", category: "Phương tiện"),
    CheatItem(code: "FLYSPRAY", name: "Máy bay Duster", desc: "Máy bay cánh quạt cổ điển", category: "Phương tiện"),
    CheatItem(code: "EXTINCT", name: "Thủy phi cơ Dodo", desc: "Máy bay hạ cánh trên mặt nước", category: "Phương tiện"),

    // MARK: - Chiến đấu (4)
    CheatItem(code: "HOTHANDS", name: "Nắm đấm phát nổ", desc: "Đấm kẻ địch văng xa và phát nổ", category: "Chiến đấu"),
    CheatItem(code: "INCENDIARY", name: "Đạn lửa", desc: "Bắn ra đạn thiêu đốt mục tiêu", category: "Chiến đấu"),
    CheatItem(code: "HIGHEX", name: "Đạn nổ", desc: "Mỗi phát bắn tạo ra vụ nổ lớn", category: "Chiến đấu"),
    CheatItem(code: "DEADEYE", name: "Làm chậm khi ngắm", desc: "Làm chậm thời gian khi giữ nút ngắm", category: "Chiến đấu"),

    // MARK: - Thế giới (5)
    CheatItem(code: "SKYFALL", name: "Rơi tự do từ trời", desc: "Thả nhân vật từ trên chín tầng mây", category: "Thế giới"),
    CheatItem(code: "SLOWMO", name: "Làm chậm toàn game", desc: "Hiệu ứng slow-motion điện ảnh", category: "Thế giới"),
    CheatItem(code: "FLOATER", name: "Trọng lực Mặt Trăng", desc: "Xe và người bay lơ lửng nhẹ", category: "Thế giới"),
    CheatItem(code: "MAKEITRAIN", name: "Đổi thời tiết", desc: "Thay đổi nắng, mưa, bão sấm chớp", category: "Thế giới"),
    CheatItem(code: "SNOW", name: "Tuyết rơi", desc: "Kích hoạt hiệu ứng tuyết rơi toàn map", category: "Thế giới")
]

struct SpawnerPreset: Identifiable {
    let id = UUID()
    let name: String
    let model: String
    let icon: String
    let category: String
}

let COMMON_VEHICLES: [SpawnerPreset] = [
    SpawnerPreset(name: "Mercedes-Benz SLK 55 AMG (Mod RPF)", model: "mbslk", icon: "car.side.fill", category: "Xe Mod (RPF)"),
    SpawnerPreset(name: "Karin Sultan", model: "sultan", icon: "car.fill", category: "Xe 4 cửa"),
    SpawnerPreset(name: "Truffade Adder (Bugatti)", model: "adder", icon: "car.side.fill", category: "Siêu xe"),
    SpawnerPreset(name: "Pegassi Zentorno", model: "zentorno", icon: "car.side.fill", category: "Siêu xe"),
    SpawnerPreset(name: "Progen T20 (McLaren)", model: "t20", icon: "car.side.fill", category: "Siêu xe"),
    SpawnerPreset(name: "Armored Kuruma (Chống đạn)", model: "kuruma", icon: "shield.righthalf.filled", category: "Bọc thép"),
    SpawnerPreset(name: "Duke O'Death", model: "duke2", icon: "shield.fill", category: "Bọc thép"),
    SpawnerPreset(name: "Oppressor Mk II (Mô tô bay)", model: "oppressor2", icon: "bolt.car.fill", category: "Đặc biệt"),
    SpawnerPreset(name: "Trực thăng Buzzard Attack", model: "buzzard", icon: "airplane", category: "Máy bay"),
    SpawnerPreset(name: "Pegassi Bati 801", model: "bati", icon: "bicycle", category: "Mô tô"),
    SpawnerPreset(name: "Sanchez (Cào cào)", model: "sanchez", icon: "bicycle", category: "Mô tô"),
    SpawnerPreset(name: "Rhino Tank (Xe tăng)", model: "rhino", icon: "shield.fill", category: "Quân sự")
]

enum CheatInputMode: String, CaseIterable, Identifiable {
    case auto = "Tự động"
    case console = "Console (`)"
    case gamepad = "Gamepad"
    var id: String { rawValue }
}

enum CheatMenuTab: String, CaseIterable, Identifiable {
    case cheats = "Lệnh Cheat"
    case spawner = "🚗 Triệu hồi Xe"
    var id: String { rawValue }
}

final class CheatManager {
    static let shared = CheatManager()
    static var isApplying: Bool { PGIsCheatInProgress() }

    static func apply(code: String, mode: CheatInputMode = .console, completion: ((Bool) -> Void)? = nil) {
        if MugoatOnlineEnabled() {
            completion?(false)
            return
        }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else {
            completion?(false)
            return
        }
        trimmed.withCString { cStr in
            switch mode {
            case .auto, .console:
                PGApplyCheatConsole(cStr)
            case .gamepad:
                PGApplyCheatGamepad(cStr)
            }
        }
        DispatchQueue.main.async {
            completion?(true)
        }
    }
}

private enum NeonPalette {
    static let bg = Color(red: 0.024, green: 0.035, blue: 0.075)
    static let card = Color(red: 0.060, green: 0.090, blue: 0.180).opacity(0.84)
    static let cardElevated = Color(red: 0.085, green: 0.125, blue: 0.240).opacity(0.92)
    static let cyan = Color(red: 0.133, green: 0.827, blue: 0.933)
    static let purple = Color(red: 0.659, green: 0.333, blue: 0.969)
    static let emerald = Color(red: 0.204, green: 0.827, blue: 0.600)
    static let amber = Color(red: 0.984, green: 0.749, blue: 0.141)
    static let stroke = Color(red: 0.133, green: 0.827, blue: 0.933).opacity(0.26)
}

struct CheatMenuView: View {
    @Environment(\.dismiss) private var dismiss
    var engineRunning: Bool = true
    @State private var selectedTab: CheatMenuTab = .cheats
    @State private var selectedCategory: String = "Tất cả"
    @State private var customCode = ""
    @State private var customVehicleModel = ""
    @State private var searchText = ""
    @State private var inputMode: CheatInputMode = .console
    @State private var toastMessage: String?
    @State private var modVehicles: [String] = []
    let onApply: (String, CheatInputMode) -> Void
    var onSpawnVehicle: ((String) -> Void)? = nil
    var onOpenMods: (() -> Void)? = nil

    private let categories = ["Tất cả", "Nhân vật", "Phương tiện", "Chiến đấu", "Thế giới"]

    private var filteredCheats: [CheatItem] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        return CHEAT_LIST.filter { item in
            let matchCat = selectedCategory == "Tất cả" || item.category == selectedCategory
            let matchQ = q.isEmpty ||
                item.name.lowercased().contains(q) ||
                item.code.lowercased().contains(q) ||
                item.desc.lowercased().contains(q) ||
                item.category.lowercased().contains(q)
            return matchCat && matchQ
        }
    }

    private var filteredVehicles: [SpawnerPreset] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return COMMON_VEHICLES }
        return COMMON_VEHICLES.filter {
            $0.name.lowercased().contains(q) ||
            $0.model.lowercased().contains(q) ||
            $0.category.lowercased().contains(q)
        }
    }

    private var filteredModVehicles: [String] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return modVehicles }
        return modVehicles.filter { $0.lowercased().contains(q) }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [NeonPalette.bg, Color(red: 0.055, green: 0.045, blue: 0.16), NeonPalette.bg],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 10) {
                headerBar

                if MugoatOnlineEnabled() {
                    onlineWarningBanner
                }

                HStack(spacing: 12) {
                    leftSidebar
                    rightContentArea
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            modVehicles = ModRuntime.catalog(ModManagerViewController.modsDirectory).vehicleModels
        }
        .overlay(alignment: .bottom) {
            if let msg = toastMessage {
                Text(msg)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(NeonPalette.cardElevated)
                    .overlay(Capsule().stroke(NeonPalette.cyan.opacity(0.65), lineWidth: 1))
                    .clipShape(Capsule())
                    .shadow(color: NeonPalette.cyan.opacity(0.35), radius: 10)
                    .padding(.bottom, 16)
            }
        }
    }

    private var headerBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.shield.fill")
                    .font(.headline)
                    .foregroundColor(NeonPalette.cyan)
                VStack(alignment: .leading, spacing: 1) {
                    Text("SUBIN V · Trainer & Spawner")
                        .font(.subheadline.weight(.heavy))
                        .foregroundColor(.white)
                    Text(engineRunning ? L10n.text("Engine đang chạy · Tác động trực tiếp") : L10n.text("Chưa vào game · Xem trước danh sách"))
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.62))
                }
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundColor(NeonPalette.cyan)
                TextField(selectedTab == .spawner ? "Tìm xe / model..." : "Tìm cheat / mã...", text: $searchText)
                    .font(.caption)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .frame(maxWidth: 230)
            .background(NeonPalette.card)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(NeonPalette.stroke, lineWidth: 1))
            .cornerRadius(10)

            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                    Text(L10n.text("Đóng"))
                }
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(NeonPalette.card)
                .overlay(Capsule().stroke(NeonPalette.stroke, lineWidth: 1))
                .clipShape(Capsule())
            }
        }
    }

    private var onlineWarningBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundColor(NeonPalette.amber)
            Text("Chế độ Cheat bị vô hiệu hóa khi chơi Online để đảm bảo công bằng.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.85))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(NeonPalette.amber.opacity(0.14))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(NeonPalette.amber.opacity(0.45), lineWidth: 1))
        .cornerRadius(10)
    }

    private var leftSidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Primary mode switcher
            ForEach(CheatMenuTab.allCases) { tab in
                let active = selectedTab == tab
                Button {
                    selectedTab = tab
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: tab == .cheats ? "sparkles" : "car.2.fill")
                            .font(.caption.bold())
                        Text(tab.rawValue)
                            .font(.caption.bold())
                        Spacer()
                    }
                    .foregroundColor(active ? Color(red: 0.015, green: 0.08, blue: 0.11) : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(active ? NeonPalette.cyan : NeonPalette.card)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(active ? NeonPalette.cyan : NeonPalette.stroke, lineWidth: 1))
                    .cornerRadius(10)
                }
            }

            if selectedTab == .cheats {
                Divider().background(Color.white.opacity(0.12))
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 5) {
                        ForEach(categories, id: \.self) { cat in
                            let selected = selectedCategory == cat
                            Button {
                                selectedCategory = cat
                            } label: {
                                HStack {
                                    Text(cat)
                                        .font(.caption.weight(selected ? .bold : .medium))
                                    Spacer()
                                }
                                .foregroundColor(selected ? NeonPalette.cyan : .white.opacity(0.72))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selected ? NeonPalette.cyan.opacity(0.16) : Color.clear)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            } else {
                Spacer()
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onOpenMods?()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill.badge.gearshape")
                            .foregroundColor(NeonPalette.amber)
                        Text("Quản lý Mod")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(NeonPalette.card)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(NeonPalette.amber.opacity(0.45), lineWidth: 1))
                    .cornerRadius(10)
                }
            }

            // Quick 1-tap tactical shortcuts
            VStack(spacing: 5) {
                quickPill("Gỡ kẹt", code: "UNFREEZE", tint: NeonPalette.amber)
                quickPill("Xóa sao", code: "LAWYERUP", tint: NeonPalette.emerald)
                quickPill("Full máu", code: "TURTLE", tint: NeonPalette.purple)
            }
        }
        .frame(width: 158)
    }

    private func quickPill(_ title: String, code: String, tint: Color) -> some View {
        Button {
            apply(code)
        } label: {
            HStack {
                Text(title)
                    .font(.caption2.bold())
                Spacer()
                Text(code)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .opacity(0.75)
            }
            .foregroundColor(tint)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.38), lineWidth: 1))
            .cornerRadius(8)
        }
    }

    private var rightContentArea: some View {
        VStack(spacing: 10) {
            if selectedTab == .cheats {
                // Input mode + custom code row
                HStack(spacing: 8) {
                    Picker("Chế độ", selection: $inputMode) {
                        ForEach(CheatInputMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 250)

                    HStack(spacing: 6) {
                        TextField("Nhập mã (vd: PAINKILLER)", text: $customCode)
                            .font(.caption)
                            .textInputAutocapitalization(.characters)
                            .disableAutocorrection(true)
                        Button(L10n.text("Áp dụng")) {
                            let c = customCode.trimmingCharacters(in: .whitespaces).uppercased()
                            guard !c.isEmpty else { return }
                            apply(c, forcedMode: .console)
                        }
                        .font(.caption.bold())
                        .foregroundColor(Color(red: 0.015, green: 0.08, blue: 0.11))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(NeonPalette.cyan)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(NeonPalette.card)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(NeonPalette.stroke, lineWidth: 1))
                    .cornerRadius(10)
                }

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(filteredCheats) { item in
                            cheatCard(item)
                        }
                    }
                    .padding(.bottom, 10)
                }
            } else {
                // Custom vehicle spawner input
                HStack(spacing: 8) {
                    TextField("Nhập model xe (vd: mbslk, sultan, t20, oppressor2)", text: $customVehicleModel)
                        .font(.caption)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(NeonPalette.card)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(NeonPalette.stroke, lineWidth: 1))
                        .cornerRadius(10)

                    Button("Triệu hồi") {
                        let m = customVehicleModel.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !m.isEmpty else { return }
                        spawnVehicle(m)
                    }
                    .font(.caption.bold())
                    .foregroundColor(Color(red: 0.015, green: 0.08, blue: 0.11))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(NeonPalette.emerald)
                    .cornerRadius(10)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !filteredModVehicles.isEmpty {
                            Text("🌟 XE MOD DLC ĐÃ CÀI")
                                .font(.caption2.bold())
                                .foregroundColor(NeonPalette.amber)
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                                ForEach(filteredModVehicles, id: \.self) { model in
                                    vehicleCard(name: "Xe Mod: \(model.uppercased())", model: model, tag: "DLC RPF", icon: "star.fill", accent: NeonPalette.amber)
                                }
                            }
                        }

                        Text("🏎️ PHƯƠNG TIỆN PHỔ BIẾN")
                            .font(.caption2.bold())
                            .foregroundColor(NeonPalette.cyan)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                            ForEach(filteredVehicles) { v in
                                vehicleCard(name: v.name, model: v.model, tag: v.category, icon: v.icon, accent: NeonPalette.cyan)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func cheatCard(_ item: CheatItem) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(item.name)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(item.code)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(NeonPalette.cyan)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(NeonPalette.cyan.opacity(0.14))
                        .cornerRadius(4)
                }
                Text(item.desc)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.62))
                    .lineLimit(2)
            }
            Spacer(minLength: 4)
            Button {
                apply(item.code)
            } label: {
                Text(L10n.text("Bật"))
                    .font(.caption2.bold())
                    .foregroundColor(Color(red: 0.015, green: 0.08, blue: 0.11))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(NeonPalette.cyan)
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .background(NeonPalette.card)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(NeonPalette.stroke, lineWidth: 1))
        .cornerRadius(12)
    }

    private func vehicleCard(name: String, model: String, tag: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.14))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("\(model) · \(tag)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Button {
                spawnVehicle(model)
            } label: {
                Text("Gọi xe")
                    .font(.caption2.bold())
                    .foregroundColor(Color(red: 0.015, green: 0.08, blue: 0.11))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(accent)
                    .cornerRadius(8)
            }
        }
        .padding(10)
        .background(NeonPalette.card)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.28), lineWidth: 1))
        .cornerRadius(12)
    }

    private func apply(_ code: String, forcedMode: CheatInputMode? = nil) {
        if MugoatOnlineEnabled() {
            withAnimation { toastMessage = "Không thể dùng cheat trong Multiplayer Online!" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { toastMessage = nil }
            }
            return
        }
        if !engineRunning {
            withAnimation { toastMessage = "Game chưa chạy: \(code)" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { toastMessage = nil }
            }
            return
        }
        let modeToUse = forcedMode ?? inputMode
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onApply(code, modeToUse)
        }
    }

    private func spawnVehicle(_ model: String) {
        if MugoatOnlineEnabled() {
            withAnimation { toastMessage = "Không thể triệu hồi xe bằng cheat trong Online!" }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { toastMessage = nil }
            }
            return
        }
        var clean = model.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if clean == "mbs1k" { clean = "mbslk" }
        guard !clean.isEmpty else { return }
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onSpawnVehicle?(clean)
        }
    }
}
