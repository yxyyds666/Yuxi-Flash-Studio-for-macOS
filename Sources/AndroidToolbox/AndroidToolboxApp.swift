import SwiftUI

@main
struct AndroidToolboxApp: App {
    var body: some Scene {
        WindowGroup("安卓刷机工具箱") {
            AppShellView()
                .frame(minWidth: 1100, minHeight: 720)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 800)
    }
}
