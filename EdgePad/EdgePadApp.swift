import SwiftUI

@main
struct EdgePadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("EdgePad", systemImage: "rectangle.inset.filled") {
            LazyPopoverContent()
        }
        .menuBarExtraStyle(.window)
    }
}

/// Lightweight wrapper that only instantiates the full PreferencesView
/// while the popover is visible. On disappear the SwiftUI tree is torn
/// down, freeing all view-hierarchy memory back to the OS.
struct LazyPopoverContent: View {
    @State private var isVisible = false

    var body: some View {
        Group {
            if isVisible {
                PreferencesView()
            } else {
                Color.clear.frame(width: 1, height: 1)
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
}