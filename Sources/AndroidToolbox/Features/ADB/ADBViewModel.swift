import Foundation
import Observation

@Observable
final class ADBViewModel {
    var devices: [DeviceInfo] = []
    var selectedDevice: DeviceInfo = .disconnected
    var shellCommand: String = ""
    var apkPath: String = ""
    var pullRemotePath: String = ""
    var pullLocalPath: String = ""
    var pushLocalPath: String = ""
    var pushRemotePath: String = ""
    var logs: String = ""

    private let service: ADBService

    init(service: ADBService = ADBService()) {
        self.service = service
    }

    func refreshDevices() {
        do {
            let list = try service.listDevices()
            devices = list.devices
            selectedDevice = list.devices.first ?? .disconnected
            appendLog("[devices] refreshed: \(list.devices.count) device(s)")
        } catch {
            appendLog("[devices] error: \(error.localizedDescription)")
        }
    }

    func executeShell() {
        guard !shellCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let result = try service.runShell(shellCommand)
            appendLog("[shell] \(shellCommand)\n\(result)")
        } catch {
            appendLog("[shell] error: \(error.localizedDescription)")
        }
    }

    func installApk() {
        guard !apkPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let result = try service.install(apkPath: apkPath)
            appendLog("[install] \(apkPath)\n\(result)")
        } catch {
            appendLog("[install] error: \(error.localizedDescription)")
        }
    }

    func pullFile() {
        guard !pullRemotePath.isEmpty, !pullLocalPath.isEmpty else { return }
        do {
            let result = try service.pull(remotePath: pullRemotePath, localPath: pullLocalPath)
            appendLog("[pull] \(pullRemotePath) -> \(pullLocalPath)\n\(result)")
        } catch {
            appendLog("[pull] error: \(error.localizedDescription)")
        }
    }

    func pushFile() {
        guard !pushLocalPath.isEmpty, !pushRemotePath.isEmpty else { return }
        do {
            let result = try service.push(localPath: pushLocalPath, remotePath: pushRemotePath)
            appendLog("[push] \(pushLocalPath) -> \(pushRemotePath)\n\(result)")
        } catch {
            appendLog("[push] error: \(error.localizedDescription)")
        }
    }

    private func appendLog(_ entry: String) {
        logs = logs.isEmpty ? entry : logs + "\n\n" + entry
    }
}
