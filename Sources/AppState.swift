import AppKit
import Darwin
import Foundation
import UserNotifications

final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var presets: [Preset] = []
    @Published var loadError: String?
    @Published var runError: String?
    @Published var noteAuthError: String?
    @Published var isRunning = false
    @Published var runningName: String = ""
    @Published var logLines: [String] = []
    @Published var detected: [DetectedJob] = []
    @Published var detectedEndedBanner: String?
    @Published var lastExit: String?

    private var spawned: Process?
    private var spawnedPID: Int32?
    private let ring = LineRing()
    private var detectTimer: Timer?
    private var knownDetected: Set<Int32> = []
    private var killWorkItem: DispatchWorkItem?

    init() {
        reload()
        startDetector()
    }

    var showEmpty: Bool {
        !isRunning && detected.isEmpty && logLines.isEmpty && lastExit == nil
    }

    func reload() {
        let loaded = PresetStore.load()
        presets = loaded.presets
        loadError = loaded.error
    }

    func persist() {
        if let err = PresetStore.save(presets) {
            loadError = err
        }
    }

    func addPreset(_ preset: Preset) {
        presets.append(preset)
        persist()
    }

    func deletePreset(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        persist()
    }

    func run(_ preset: Preset) {
        guard !isRunning else { return }
        var cwd = preset.cwd
        if cwd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            guard let picked = ProcessSupport.pickDirectory() else { return }
            cwd = picked
        }
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: cwd, isDirectory: &isDir), isDir.boolValue else {
            runError = "Working directory does not exist: \(cwd)"
            return
        }

        runError = nil
        detectedEndedBanner = nil
        lastExit = nil
        ring.clear()
        logLines = []
        isRunning = true
        runningName = preset.name

        let process = Process()
        process.executableURL = URL(fileURLWithPath: preset.command)
        process.arguments = preset.arguments
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        process.environment = ProcessInfo.processInfo.environment
        let out = Pipe()
        let err = Pipe()
        process.standardOutput = out
        process.standardError = err

        out.fileHandleForReading.readabilityHandler = { [weak self] handle in
            self?.ingest(handle.availableData)
        }
        err.fileHandleForReading.readabilityHandler = { [weak self] handle in
            self?.ingest(handle.availableData)
        }

        process.terminationHandler = { [weak self] proc in
            out.fileHandleForReading.readabilityHandler = nil
            err.fileHandleForReading.readabilityHandler = nil
            self?.ingest(out.fileHandleForReading.readDataToEndOfFile())
            self?.ingest(err.fileHandleForReading.readDataToEndOfFile())
            let code = proc.terminationStatus
            DispatchQueue.main.async {
                self?.finishRun(name: preset.name, code: code)
            }
        }

        do {
            try process.run()
            spawned = process
            spawnedPID = process.processIdentifier
        } catch {
            isRunning = false
            runningName = ""
            spawned = nil
            spawnedPID = nil
            runError = error.localizedDescription
        }
    }

    func stop() {
        guard let process = spawned, process.isRunning else { return }
        process.terminate()
        killWorkItem?.cancel()
        let pid = process.processIdentifier
        let work = DispatchWorkItem {
            if kill(pid, 0) == 0 {
                kill(pid, SIGKILL)
            }
        }
        killWorkItem = work
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: work)
    }

    func copyLog() {
        let text = ring.joined()
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func ingest(_ data: Data) {
        guard !data.isEmpty, let text = String(data: data, encoding: .utf8), !text.isEmpty else { return }
        ring.append(text)
        let snap = ring.snapshot()
        DispatchQueue.main.async { [weak self] in
            self?.logLines = snap
        }
    }

    private func finishRun(name: String, code: Int32) {
        killWorkItem?.cancel()
        killWorkItem = nil
        isRunning = false
        runningName = ""
        spawned = nil
        spawnedPID = nil
        logLines = ring.snapshot()
        if code == 0 {
            lastExit = "\(name) succeeded"
        } else {
            lastExit = "\(name) failed (code \(code))"
        }
        notify(body: lastExit ?? "")
    }

    private func notify(body: String) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Build"
        content.body = body
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req) { [weak self] error in
            if let error {
                DispatchQueue.main.async {
                    self?.runError = error.localizedDescription
                }
            }
        }
    }

    private func startDetector() {
        detectTimer?.invalidate()
        let timer = Timer(timeInterval: 2, repeats: true) { [weak self] _ in
            self?.pollDetected()
        }
        timer.tolerance = 0.3
        RunLoop.main.add(timer, forMode: .common)
        detectTimer = timer
        pollDetected()
    }

    private func pollDetected() {
        let skip = spawnedPID
        DispatchQueue.global(qos: .utility).async { [weak self] in
            do {
                var jobs = try ProcessSupport.listProcesses()
                if let skip {
                    jobs.removeAll { $0.pid == skip }
                }
                let selfPid = ProcessInfo.processInfo.processIdentifier
                jobs.removeAll { $0.pid == selfPid }
                DispatchQueue.main.async {
                    self?.applyDetected(jobs)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.runError = error.localizedDescription
                }
            }
        }
    }

    private func applyDetected(_ jobs: [DetectedJob]) {
        let current = Set(jobs.map(\.pid))
        if !knownDetected.isEmpty, current.isEmpty {
            detectedEndedBanner = "Detected job ended"
        }
        if !current.isEmpty {
            detectedEndedBanner = nil
        }
        knownDetected = current
        detected = jobs
    }
}
