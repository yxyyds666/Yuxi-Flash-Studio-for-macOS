import Foundation

struct DeviceInfo: Equatable, Identifiable {
    let serial: String
    let model: String
    let state: String

    var id: String { serial }
    var isOnline: Bool { state == "device" }

    static let disconnected = DeviceInfo(serial: "-", model: "Unknown", state: "Disconnected")
}
