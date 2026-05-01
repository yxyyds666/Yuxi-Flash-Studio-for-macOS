import SwiftUI

@main
struct AndroidToolboxApp: App {
    var body: some Scene {
        WindowGroup("Android Toolbox") {
            AppShellView()
                .frame(minWidth: 1100, minHeight: 720)
        }
        .windowResizability(.contentSize)
    }
}
