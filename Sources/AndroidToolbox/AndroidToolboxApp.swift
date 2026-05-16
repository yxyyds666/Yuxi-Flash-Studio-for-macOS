import SwiftUI
import AppKit

@main
struct AndroidToolboxApp: App {
    init() {
        if let url = Bundle.module.url(forResource: "app-icon", withExtension: "png"),
           let icon = NSImage(contentsOf: url) {
            NSApplication.shared.applicationIconImage = icon
        }
    }

    var body: some Scene {
        WindowGroup("Yuxi Flash Studio") {
            AppShellView()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 860)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
