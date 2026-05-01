import Foundation
import Observation

struct ADBRebootAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let target: ADBRebootTarget
}

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

    let rebootActions: [ADBRebootAction] = [
        .init(title: "重启系统", subtitle: "adb reboot", target: .system),
        .init(title: "重启 Fastboot", subtitle: "adb reboot fastboot", target: .fastboot),
        .init(title: "重启 Bootloader", subtitle: "adb reboot bootloader", target: .bootloader),
        .init(title: "重启 EDL", subtitle: "adb reboot edl", target: .edl),
        .init(title: "重启 Recovery", subtitle: "adb reboot recovery", target: .recovery),
        .init(title: "重启 Sideload", subtitle: "adb reboot sideload", target: .sideload)
    ]

    private let service: ADBService

    init(service: ADBService = ADBService()) {
        self.service = service
    }

    func refreshDevices() {
        do {
            let list = try service.listDevices()
            devices = list.devices
            selectedDevice = list.devices.first ?? .disconnected
            appendLog("[设备] 刷新完成：共 \(list.devices.count) 台")
        } catch {
            appendLog("[设备] 刷新失败：\(error.localizedDescription)")
        }
    }

    func executeShell() {
        guard !shellCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let result = try service.runShell(shellCommand)
            appendLog("[Shell] \(shellCommand)\n\(result)")
        } catch {
            appendLog("[Shell] 执行失败：\(error.localizedDescription)")
        }
    }

    func installApk() {
        guard !apkPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            let result = try service.install(apkPath: apkPath)
            appendLog("[安装] \(apkPath)\n\(result)")
        } catch {
            appendLog("[安装] 失败：\(error.localizedDescription)")
        }
    }

    func pullFile() {
        guard !pullRemotePath.isEmpty, !pullLocalPath.isEmpty else { return }
        do {
            let result = try service.pull(remotePath: pullRemotePath, localPath: pullLocalPath)
            appendLog("[拉取] \(pullRemotePath) -> \(pullLocalPath)\n\(result)")
        } catch {
            appendLog("[拉取] 失败：\(error.localizedDescription)")
        }
    }

    func pushFile() {
        guard !pushLocalPath.isEmpty, !pushRemotePath.isEmpty else { return }
        do {
            let result = try service.push(localPath: pushLocalPath, remotePath: pushRemotePath)
            appendLog("[推送] \(pushLocalPath) -> \(pushRemotePath)\n\(result)")
        } catch {
            appendLog("[推送] 失败：\(error.localizedDescription)")
        }
    }

    func reboot(to target: ADBRebootTarget, label: String) {
        do {
            let result = try service.reboot(target)
            appendLog("[重启] \(label)\n\(result)")
        } catch {
            appendLog("[重启] \(label) 失败：\(error.localizedDescription)")
        }
    }

    private func appendLog(_ entry: String) {
        logs = logs.isEmpty ? entry : logs + "\n\n" + entry
    }
}
