import AppKit
import Darwin
import Foundation

final class LineRing {
    private var lines: [String] = []
    private let cap = 200
    private let lock = NSLock()

    func append(_ chunk: String) {
        guard !chunk.isEmpty else { return }
        let pieces = chunk.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        lock.lock()
        defer { lock.unlock() }
        lines.append(contentsOf: pieces)
        while lines.count > cap {
            lines.removeFirst()
        }
    }

    func snapshot() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return lines
    }

    func joined() -> String {
        snapshot().joined(separator: "\n")
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        lines.removeAll()
    }
}

enum ProcessSupport {
    static let detectNeedles = ["pnpm test", "npm test", "cargo test", "swift test", "xcodebuild"]

    static func parsePS(_ text: String) -> [DetectedJob] {
        var jobs: [DetectedJob] = []
        for raw in text.split(whereSeparator: \.isNewline) {
            let parts = String(raw).split(
                maxSplits: 2,
                omittingEmptySubsequences: true,
                whereSeparator: { $0.isWhitespace }
            )
            guard parts.count >= 2, let pid = Int32(parts[0]) else { continue }
            let comm = String(parts[1])
            let args = parts.count > 2 ? String(parts[2]) : comm
            if comm == "ps" { continue }
            if detectNeedles.contains(where: { args.contains($0) }) {
                jobs.append(DetectedJob(pid: pid, comm: comm, args: args))
            }
        }
        return jobs
    }

    static func listProcesses() throws -> [DetectedJob] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-axo", "pid=,comm=,args="]
        let out = Pipe()
        let err = Pipe()
        process.standardOutput = out
        process.standardError = err
        try process.run()
        process.waitUntilExit()
        let stdout = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        if process.terminationStatus != 0 {
            let message = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
            throw NSError(
                domain: "FocusBuild",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: message.isEmpty ? "ps failed" : message]
            )
        }
        return parsePS(stdout)
    }

    static func pickDirectory() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Choose folder"
        panel.message = "Choose a working directory for this preset"
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK else { return nil }
        return panel.url?.path
    }
}
