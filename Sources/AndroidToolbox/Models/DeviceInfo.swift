import Foundation

struct DeviceInfo: Equatable {
    var serial: String
    var model: String
    var state: String

    static let disconnected = DeviceInfo(serial: "-", model: "Unknown", state: "Disconnected")
}
