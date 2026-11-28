import Foundation
import Metal
import UIKit
import os

/// Graphics presets. The engine reads quality settings once at boot; only the
/// resolution can change while it runs.
enum GraphicsPreset: Int, CaseIterable {
    case battery, performance, balanced, quality, ultra, max

    /// A physical-device policy, not an artistic quality setting. Older phones
    /// must not expose the same resolution/FPS envelope as ProMotion devices.
    static func clamped(_ preset: GraphicsPreset, for tier: DeviceTier) -> GraphicsPreset {
        switch tier.performanceClass {
        case .legacy: return .battery
        case .low: return GraphicsPreset(rawValue: min(preset.rawValue, GraphicsPreset.performance.rawValue)) ?? .performance
        case .mid: return GraphicsPreset(rawValue: min(preset.rawValue, GraphicsPreset.balanced.rawValue)) ?? .balanced
        case .high: return preset
        }
    }

    var title: String { [L10n.text("Tiết kiệm pin"), L10n.text("Ưu tiên mượt"), L10n.text("Cân bằng"), L10n.text("Rõ nét"), L10n.text("Cao"), L10n.text("Tối đa (4K)")][rawValue] }
    /// Render height in pixels; width follows the screen's shape.
    var height: Int { [432, 540, 720, 900, 1080, 2160][rawValue] }
    var detail: String {
        [L10n.text("432p · ít tốn RAM và pin"), L10n.text("540p · giảm hiệu ứng nặng"), L10n.text("720p · cân bằng hình ảnh và tốc độ"),
         L10n.text("900p · tăng chi tiết và khoảng nhìn"), L10n.text("1080p · bóng và phản chiếu cao"),
         L10n.text("2160p (4K) · chi tiết đồ họa tối đa (Native 4K)")][rawValue]
    }

    /// Engine command-line options. Only shaderQuality is pinned on the CLI (the
    /// low shader set is mostly missing, and Quality 2 shaders are not compiled for Metal).
    /// All other graphics values come from settings.xml so Pause Menu > Graphics > Apply Changes works.
    var engineOptions: [String] {
        return ["-shaderQuality=1"]
    }
}

/// What this device can afford, measured before the engine starts.
struct DeviceTier {
    /// Measured OS process allowance for diagnostics; never an allocation cap.
    let processAllowanceMB: Int
    let physicalMemoryMB: Int
    let model: String
    let supportsBCTextures: Bool

    enum PerformanceClass { case legacy, low, mid, high }
    var performanceClass: PerformanceClass {
        // A11/2 GB-class devices need a hard 30 FPS/low-memory envelope.
        if physicalMemoryMB <= 3000 || model.hasPrefix("iPhone10") { return .legacy }
        if physicalMemoryMB <= 4000 { return .low }
        if physicalMemoryMB <= 6000 { return .mid }
        return .high
    }

    var maximumRenderHeight: Int {
        switch performanceClass {
        case .legacy: return 540
        case .low: return 720
        case .mid: return 1080
        case .high: return 1440
        }
    }

    var allowedFrameRates: [Int] {
        switch performanceClass {
        case .legacy: return [30]
        case .low: return [30, 60]
        case .mid, .high: return [30, 60, 0]
        }
    }

    static func probe() -> DeviceTier {
        var info = utsname(); uname(&info)
        let model = withUnsafeBytes(of: &info.machine) { String(decoding: $0.prefix { $0 != 0 }, as: UTF8.self) }
        let device = MTLCreateSystemDefaultDevice()
        let supportsBC: Bool
        let memMB = Int(ProcessInfo.processInfo.physicalMemory / 1_048_576)
        if #available(iOS 16.4, *) { supportsBC = device?.supportsBCTextureCompression ?? false }
        else { supportsBC = false }
        return DeviceTier(processAllowanceMB: Self.measureProcessAllowanceMB(),
                          physicalMemoryMB: memMB,
                          model: model,
                          supportsBCTextures: supportsBC)
    }

    /// Jetsam limit = memory still available + what the app already uses.
    private static func measureProcessAllowanceMB() -> Int {
        var vm = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &vm) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count) }
        }
        let footprint = result == KERN_SUCCESS ? Int(vm.phys_footprint) : 0
        return (Int(os_proc_available_memory()) + footprint) / 1_048_576
    }

    /// Recommend from the device's actual RAM; all presets remain selectable.
    var recommended: GraphicsPreset {
        physicalMemoryMB < 3400 ? .battery : physicalMemoryMB < 4600 ? .performance : physicalMemoryMB < 6400 ? .balanced : physicalMemoryMB < 10000 ? .quality : physicalMemoryMB < 12000 ? .ultra : .max
    }
    /// Every preset can be chosen; those above the recommended one show a warning.
    var allowed: [GraphicsPreset] { GraphicsPreset.allCases }
    /// Presets shown with a warning because they may run out of memory or heat up.
    func risky(_ preset: GraphicsPreset) -> Bool { preset.rawValue > recommended.rawValue }
    var summary: String { "\(model) · \(String(format: "%.1f", Double(physicalMemoryMB) / 1024)) GB RAM\(supportsBCTextures ? " · BC textures" : "")" }
}

enum GraphicsConfiguration {
    /// The screen's height in pixels (the "Native" resolution).
    static var nativeHeight: Int {
        let screen = UIScreen.main
        let raw = Int(min(screen.nativeBounds.width, screen.nativeBounds.height))
        return raw > 0 ? raw : 720
    }
    /// Resolutions offered in Settings, besides "Auto" (the detail preset's own).
    static var resolutionChoices: [Int] {
        let standard = [540, 720, 900, 1080, 1290, 1440, 1620, 2160]
        var list = standard
        if !list.contains(nativeHeight) && nativeHeight >= 540 {
            list.append(nativeHeight)
        }
        list.sort()
        return list
    }
    /// Width/height to render at: the chosen height (or the preset's), shaped like the screen so the
    /// picture is not stretched.
    static func size(for preset: GraphicsPreset, renderHeight: Int, screen: CGSize, matchScreenShape: Bool) -> (Int, Int) {
        let aspect = matchScreenShape && screen.height > 0 ? max(screen.width, screen.height) / min(screen.width, screen.height) : 16.0 / 9.0
        var height = Double(renderHeight > 0 ? renderHeight : preset.height)
        height = min(max(height, 360), 2160.0)
        let width = min(height * aspect, 3840.0)
        func even(_ value: Double) -> Int { Int(value.rounded()) & ~1 }
        return (max(even(width), 320), max(even(height), 240))
    }

    /// Pass the chosen settings to the engine. Call before PGStartEngine.
    static func apply(_ settings: GameSettings, screen: CGSize) -> String {
        PGSetEngineMemoryMB(Int32(settings.engineMemoryMB))
        let preset = settings.graphicsPreset
        let requestedHeight = settings.renderHeight > 0 ? settings.renderHeight : preset.height
        let safeHeight = min(requestedHeight, settings.tier.maximumRenderHeight)
        let (width, height) = size(for: preset, renderHeight: safeHeight, screen: screen, matchScreenShape: settings.matchScreenShape)
        let options = preset.engineOptions
        var pointers = options.map { strdup($0) }
        defer { pointers.forEach { free($0) } }
        pointers.withUnsafeMutableBufferPointer { buffer in
            buffer.baseAddress!.withMemoryRebound(to: UnsafePointer<CChar>?.self, capacity: buffer.count) {
                PGConfigureEngine($0, UInt32(buffer.count), Int32(width), Int32(height), settings.frameRateCap == 0 ? 0 : settings.frameRateCap == 60 ? 1 : 2)
            }
        }
        // Even frame pacing when the cap is below the screen's refresh rate (30 on 60 Hz, 30/60 on 120 Hz).
        let cap = settings.frameRateCap
        PGSetPresentPacing(cap > 0 && cap < UIScreen.main.maximumFramesPerSecond ? 1.0 / Double(cap) : 0)
        return "\(preset.title) \(width)×\(height) at \(GameSettings.frameRateTitle(settings.frameRateCap))"
    }
}
