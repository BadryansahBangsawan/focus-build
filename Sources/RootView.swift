import SwiftUI

struct RootView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Focus Build")
                    .font(.headline)
                Spacer()
                if state.isRunning {
                    ProgressView()
                        .controlSize(.small)
                    Text(state.runningName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Stop") { state.stop() }
                }
            }

            if let err = state.loadError, !err.isEmpty {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
            if let err = state.runError, !err.isEmpty {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
            if let err = state.noteAuthError, !err.isEmpty {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
            if let banner = state.detectedEndedBanner, !banner.isEmpty {
                Text(banner)
                    .foregroundStyle(.orange)
            }
            if let exit = state.lastExit {
                Text(exit)
                    .foregroundStyle(exit.contains("succeeded") ? Color.secondary : Color.red)
            }

            if state.showEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Run a preset or wait for a detected test process")
                    if let first = state.presets.first {
                        Button("Run \(first.name)") { state.run(first) }
                    } else {
                        Button("Add a preset in Settings") { openSettings() }
                    }
                }
            }

            if !state.presets.isEmpty {
                Text("Presets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(state.presets) { preset in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                            Text(preset.cwd.isEmpty ? "cwd: choose on run" : preset.cwd)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        Button("Run") { state.run(preset) }
                            .disabled(state.isRunning)
                    }
                }
            }

            if !state.detected.isEmpty {
                Text("Detected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(state.detected) { job in
                    Text("Detected: pid \(job.pid) \(job.args)")
                        .font(.caption.monospaced())
                        .lineLimit(2)
                        .textSelection(.enabled)
                }
            }

            if !state.logLines.isEmpty {
                HStack {
                    Text("Last log")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Copy last log") { state.copyLog() }
                }
                ScrollView {
                    Text(state.logLines.joined(separator: "\n"))
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 140)
            }

            HStack {
                Button("Settings…") { openSettings() }
                Spacer()
            }
        }
        .funPanel()
        .background(.regularMaterial)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.isRunning)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.detected.count)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.showEmpty)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.detectedEndedBanner)
    }
}
