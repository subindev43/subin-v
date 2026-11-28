import Foundation

enum ModRuntime {
    struct Catalog {
        var packs: [ModPack] = []
        var problems: [String] = []
        var models: [String] { packs.flatMap(\.models).sorted() }
        /// Spawnable vehicle model names (vehicles.meta), for the spawner lists.
        var vehicleModels: [String] { packs.flatMap(\.vehicleModels).sorted() }
    }
    static func catalog(_ directory: URL) -> Catalog {
        var result = Catalog(), names = Set<String>(), models = Set<String>()
        let files = ModFiles.scan(directory).filter { $0.isEnabled && $0.url.pathExtension.lowercased() == "rpf" }.sorted { $0.name < $1.name }
        for file in files {
            do {
                let pack = try ModPack(url: file.url)
                guard names.insert(pack.name).inserted else { throw ModError("Trùng gói DLC \(pack.name). Chỉ bật một phiên bản của gói này.") }
                guard models.isDisjoint(with: pack.models) else { throw ModError("Trùng tên xe giữa các mod: \(pack.models.joined(separator: ", ")).") }
                models.formUnion(pack.models); result.packs.append(pack)
            } catch let error as ModError {
                if file.url.lastPathComponent.lowercased() == "dlc.rpf" || error.message.contains("Enhanced") || error.message.contains("Trùng") {
                    result.problems.append(file.name + ": " + error.localizedDescription)
                }
            } catch {
                if file.url.lastPathComponent.lowercased() == "dlc.rpf" {
                    result.problems.append(file.name + ": " + error.localizedDescription)
                }
            }
        }
        return result
    }

    /// Builds baseline dlcList.xml matching the exact x64/dlcPacks present in baseManifest.
    static func defaultDlcList(from baseManifest: URL) -> Data? {
        guard let data = try? Data(contentsOf: baseManifest),
              let parsed = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let files = parsed["files"] as? [[Any]] else { return nil }
        var seen = Set<String>()
        var packs: [String] = []
        for entry in files {
            guard let path = entry.first as? String, path.lowercased().hasPrefix("x64/dlcpacks/") else { continue }
            let parts = path.split(separator: "/")
            if parts.count >= 3 {
                let packName = String(parts[2])
                if seen.insert(packName.lowercased()).inserted { packs.append(packName) }
            }
        }
        var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<Paths>\n"
        for pack in packs.sorted() {
            xml += "\t<Item>platform:\\dlcPacks\\\(pack)\\</Item>\n"
        }
        xml += "</Paths>\n"
        return Data(xml.utf8)
    }

    /// Builds a manifest overlay. Original game files and their sizes remain untouched.
    static func prepare(baseManifest: URL, mods: URL, runtime: URL, dlcList: Data) throws -> (URL, Catalog) {
        let catalog = catalog(mods)
        if !catalog.problems.isEmpty { throw ModError(catalog.problems.joined(separator: "\n")) }
        guard var manifest = try JSONSerialization.jsonObject(with: Data(contentsOf: baseManifest)) as? [String: Any],
              var files = manifest["files"] as? [[Any]] else { throw ModError("Manifest gốc không hợp lệ.") }
        var indexByLowerPath: [String: Int] = [:]
        indexByLowerPath.reserveCapacity(files.count)
        for (idx, entry) in files.enumerated() {
            if let path = entry.first as? String { indexByLowerPath[path.lowercased()] = idx }
        }
        // Loose replacement files placed under mods/ matching exact relative manifest paths (e.g. mods/common/data/handling.meta).
        let looseOverrides: [(String, URL)] = ModFiles.scan(mods).compactMap { entry in
            guard entry.isEnabled else { return nil }
            let lower = entry.name.lowercased()
            return indexByLowerPath[lower] != nil ? (entry.name, entry.url) : nil
        }
        guard !catalog.packs.isEmpty || !looseOverrides.isEmpty else { return (baseManifest, catalog) }
        try FileManager.default.createDirectory(at: runtime, withIntermediateDirectories: true)
        var overrides: [String: String] = [:]
        func add(_ path: String, file: URL) throws {
            let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            if let index = indexByLowerPath[path.lowercased()] {
                // Preserve indices used by preloader/cache and by the engine.
                let original = files[index][0] as! String
                files[index][1] = size; overrides[original] = file.path
            } else {
                indexByLowerPath[path.lowercased()] = files.count
                files.append([path, size, 0]); overrides[path] = file.path
            }
        }
        for (path, file) in looseOverrides {
            try add(path, file: file)
        }
        if !catalog.packs.isEmpty {
            guard var xml = String(data: dlcList, encoding: .utf8),
                  xml.range(of: "</Paths>", options: .caseInsensitive) != nil else { throw ModError("Thiếu danh sách DLC gốc hợp lệ.") }
            for pack in catalog.packs {
                let prefix = "x64/dlcPacks/" + pack.name + "/"
                try add(prefix + "dlc.rpf", file: pack.url)
                for name in ["setup2.xml", "content.xml"] {
                    guard let entry = pack.archive.entries.first(where: { $0.path == name }) else { throw ModError("DLC thiếu \(name)") }
                    let target = runtime.appendingPathComponent(pack.name + "-" + name)
                    try pack.archive.metadata(entry).write(to: target, options: .atomic)
                    try add(prefix + name, file: target)
                }
                // This engine mounts DLC through platform:\dlcPacks, not update/x64/dlcpacks.
                let path = "platform:\\dlcPacks\\" + pack.name + "\\"
                if !xml.lowercased().contains(path.lowercased()) {
                    if let range = xml.range(of: "</Paths>", options: .caseInsensitive) {
                        xml.replaceSubrange(range, with: "\t<Item>" + path + "</Item>\n" + xml[range])
                    }
                }
            }
            let list = runtime.appendingPathComponent("dlcList.xml")
            try Data(xml.utf8).write(to: list, options: .atomic)
            try add("common/data/dlcList.xml", file: list)
        }
        manifest["files"] = files; manifest["_mugoatOverrides"] = overrides
        let output = runtime.appendingPathComponent("manifest.json")
        try JSONSerialization.data(withJSONObject: manifest, options: [.sortedKeys]).write(to: output, options: .atomic)
        return (output, catalog)
    }

    static func importPack(_ source: URL, into mods: URL) throws -> ModPack {
        let pack = try ModPack(url: source), directory = mods.appendingPathComponent(pack.name)
        let fm = FileManager.default
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        let temporary = directory.appendingPathComponent("import-" + UUID().uuidString + ".rpf")
        let target = directory.appendingPathComponent("dlc.rpf")
        try fm.copyItem(at: source, to: temporary)
        defer { try? fm.removeItem(at: temporary) }
        if fm.fileExists(atPath: target.path) { _ = try fm.replaceItemAt(target, withItemAt: temporary) }
        else { try fm.moveItem(at: temporary, to: target) }
        return try ModPack(url: target)
    }
}
