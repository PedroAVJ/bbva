import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        FontRegistrar.registerBundledFonts()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct BBVAApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var store = DashboardStore()

    var body: some Scene {
        WindowGroup("BBVA", id: "main") {
            ContentView(store: store)
                .background(WindowConfigurator())
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 420, height: 566)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
