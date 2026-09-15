import Foundation

struct Preset: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var cwd: String
    var command: String
    var arguments: [String]
}

struct DetectedJob: Identifiable, Equatable {
    var id: Int32 { pid }
    let pid: Int32
    let comm: String
    let args: String
}

enum PresetStore {
    static let displayName = "Focus Build"
    static let fileName = "presets.json"

    static var directoryURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/\(displayName)", isDirectory: true)
    }

    static var fileURL: URL {
        directoryURL.appendingPathComponent(fileName)
    }

    static func defaultPresets() -> [Preset] {
        [
            Preset(id: UUID(), name: "pnpm test", cwd: "", command: "/usr/bin/env", arguments: ["pnpm", "test"]),
            Preset(id: UUID(), name: "npm test", cwd: "", command: "/usr/bin/env", arguments: ["npm", "test"]),
            Preset(id: UUID(), name: "cargo test", cwd: "", command: "/usr/bin/env", arguments: ["cargo", "test"]),
            Preset(id: UUID(), name: "swift test", cwd: "", command: "/usr/bin/env", arguments: ["swift", "test"]),
        ]
    }

    static func load() -> (presets: [Preset], error: String?) {
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        } catch {
            return ([], error.localizedDescription)
        }
        if !fm.fileExists(atPath: fileURL.path) {
            let defaults = defaultPresets()
            if let saveError = save(defaults) {
                return (defaults, saveError)
            }
            return (defaults, nil)
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Preset].self, from: data)
            return (decoded, nil)
        } catch {
            return ([], error.localizedDescription)
        }
    }

    static func save(_ presets: [Preset]) -> String? {
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(presets)
            try data.write(to: fileURL, options: .atomic)
            return nil
        } catch {
            return error.localizedDescription
        }
    }
}
