import SwiftUI

@main
struct EdgePadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("EdgePad", systemImage: "hand.point.up.left") {
            Button("Settings…") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            Divider()
            Button("Quit EdgePad") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }

        Settings {
            PreferencesView()
        }
    }
}