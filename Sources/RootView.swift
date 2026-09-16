import SwiftUI

struct RootView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: FunTheme.sectionSpacing) {
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
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            if let err = state.runError, !err.isEmpty {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
            if let err = state.noteAuthError, !err.isEmpty {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
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
                ExtraEmptyState(
                    title: "Nothing running",
                    detail: "Run a preset or wait for a detected test process.",
                    actionTitle: state.presets.first.map { "Run \($0.name)" } ?? "Open Settings",
                    action: {
                        if let first = state.presets.first {
                            state.run(first)
                        } else {
                            openSettings()
                        }
                    }
                )
            }

            if !state.presets.isEmpty {
                VStack(alignment: .leading, spacing: FunTheme.innerSpacing) {
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
                        .extraRowSurface()
                    }
                }
            }

            if !state.detected.isEmpty {
                VStack(alignment: .leading, spacing: FunTheme.innerSpacing) {
                    Text("Detected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(state.detected) { job in
                        Text("Detected: pid \(job.pid) \(job.args)")
                            .font(.caption.monospaced())
                            .lineLimit(2)
                            .textSelection(.enabled)
                            .extraRowSurface()
                    }
                }
            }

            if !state.logLines.isEmpty {
                VStack(alignment: .leading, spacing: FunTheme.innerSpacing) {
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
            }

            ExtraSettingsFooter()
        }
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.isRunning)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.detected.count)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.showEmpty)
        .animation(reduceMotion ? nil : FunTheme.spring, value: state.detectedEndedBanner)
        .funPanel()
    }
}
