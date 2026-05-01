import Foundation
import Observation

@Observable
final class FastbootViewModel {
    var devices: [DeviceInfo] = []
    var selectedDevice: DeviceInfo = .disconnected
    var varKey: String = "product"
    var logs: String = ""

    private let service: FastbootService

    init(service: FastbootService = FastbootService()) {
        self.service = service
    }

    func refreshDevices() {
        do {
            let list = try service.listDevices()
            devices = list
            selectedDevice = list.first ?? .disconnected
            appendLog("[fastboot devices] refreshed: \(list.count) device(s)")
        } catch {
            appendLog("[fastboot devices] error: \(error.localizedDescription)")
        }
    }

    func readVar() {
        guard !varKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let result = try service.getVar(varKey)
            appendLog("[getvar] \(varKey)\n\(result)")
        } catch {
            appendLog("[getvar] error: \(error.localizedDescription)")
        }
    }

    func rebootBootloader() {
        do {
            let result = try service.rebootBootloader()
            appendLog("[reboot-bootloader]\n\(result)")
        } catch {
            appendLog("[reboot-bootloader] error: \(error.localizedDescription)")
        }
    }

    func reboot() {
        do {
            let result = try service.reboot()
            appendLog("[reboot]\n\(result)")
        } catch {
            appendLog("[reboot] error: \(error.localizedDescription)")
        }
    }

    private func appendLog(_ entry: String) {
        logs = logs.isEmpty ? entry : logs + "\n\n" + entry
    }
}
