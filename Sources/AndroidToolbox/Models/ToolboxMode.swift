import Foundation

enum ToolboxMode: String, CaseIterable, Identifiable {
    case adb = "ADB"
    case fastboot = "Fastboot"
    case edl = "EDL (9008)"

    var id: String { rawValue }
}
