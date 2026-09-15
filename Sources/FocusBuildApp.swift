import AppKit
import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error {
                DispatchQueue.main.async {
                    AppState.shared.noteAuthError = error.localizedDescription
                }
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

@main
struct FocusBuildApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = AppState.shared

    var body: some Scene {
        MenuBarExtra("Focus Build", systemImage: "hammer") {
            RootView()
                .environmentObject(state)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(state)
        }
    }
}
