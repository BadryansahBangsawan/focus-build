import AppKit
import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @State private var openAtLogin = SMAppService.mainApp.status == .enabled
    @State private var loginError = ""
    @State private var newName = ""
    @State private var newCwd = ""
    @State private var newCommand = "/usr/bin/env"
    @State private var newArgs = ""
    @State private var formError = ""

    var body: some View {
        Form {
            Section("Presets") {
                if state.presets.isEmpty {
                    Text("No presets")
                        .foregroundStyle(.secondary)
                }
                ForEach(state.presets) { preset in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                            Text("\(preset.command) \(preset.arguments.joined(separator: " "))")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button("Delete", role: .destructive) {
                            state.deletePreset(preset)
                        }
                    }
                }
            }
            Section("Add preset") {
                TextField("Name", text: $newName)
                HStack {
                    TextField("Working directory (empty = ask)", text: $newCwd)
                    Button("Choose…") {
                        if let path = ProcessSupport.pickDirectory() {
                            newCwd = path
                        }
                    }
                }
                TextField("Command", text: $newCommand)
                TextField("Arguments (one per line)", text: $newArgs, axis: .vertical)
                    .lineLimit(2...6)
                if !formError.isEmpty {
                    Label(formError, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
                Button("Add") { addPreset() }
            }
            Section("Login") {
                Toggle("Open at Login", isOn: Binding(
                    get: { openAtLogin },
                    set: { toggleLogin($0) }
                ))
                if !loginError.isEmpty {
                    Label(loginError, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
            Section {
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: FunTheme.panelWidth)
        .padding(12)
        .onAppear {
            openAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func addPreset() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        let command = newCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            formError = "Name is required"
            return
        }
        guard !command.isEmpty else {
            formError = "Command is required"
            return
        }
        let args = newArgs
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let preset = Preset(
            id: UUID(),
            name: name,
            cwd: newCwd.trimmingCharacters(in: .whitespacesAndNewlines),
            command: command,
            arguments: args
        )
        state.addPreset(preset)
        formError = ""
        newName = ""
        newCwd = ""
        newCommand = "/usr/bin/env"
        newArgs = ""
    }

    private func toggleLogin(_ on: Bool) {
        do {
            if on {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginError = ""
        } catch {
            loginError = error.localizedDescription
        }
        openAtLogin = SMAppService.mainApp.status == .enabled
    }
}
