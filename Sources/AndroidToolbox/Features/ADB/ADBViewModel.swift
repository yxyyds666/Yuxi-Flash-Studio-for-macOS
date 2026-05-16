import Foundation
import Observation
import AppKit

struct ADBRebootAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let target: ADBRebootTarget
}

struct ADBFileEntry: Identifiable {
    let path: String
    let name: String
    let isDirectory: Bool

    var id: String { path }
}

@Observable
@MainActor
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
    var isAutoRefreshing: Bool = false

    var localCurrentPath: String = NSHomeDirectory()
    var remoteCurrentPath: String = "/sdcard"
    var localEntries: [ADBFileEntry] = []
    var remoteEntries: [ADBFileEntry] = []
    var selectedLocalPath: String = ""
    var selectedRemotePath: String = ""
    var isRootModeEnabled: Bool = false

    var canPushSelected: Bool {
        guard !selectedLocalPath.isEmpty else { return false }
        return localEntries.first(where: { $0.path == selectedLocalPath })?.isDirectory == false
    }

    var canPullSelected: Bool {
        guard !selectedRemotePath.isEmpty else { return false }
        return remoteEntries.first(where: { $0.path == selectedRemotePath })?.isDirectory == false
    }

    let rebootActions: [ADBRebootAction] = [
        .init(title: "重启系统", subtitle: "adb reboot", target: .system),
        .init(title: "重启 Fastboot", subtitle: "adb reboot fastboot", target: .fastboot),
        .init(title: "重启 Bootloader", subtitle: "adb reboot bootloader", target: .bootloader),
        .init(title: "重启 EDL", subtitle: "adb reboot edl", target: .edl),
        .init(title: "重启 Recovery", subtitle: "adb reboot recovery", target: .recovery),
        .init(title: "重启 Sideload", subtitle: "adb reboot sideload", target: .sideload)
    ]

    private let service: ADBService
    private var refreshTimer: Timer?
    private let appLogStore: AppLogStore

    init(service: ADBService = ADBService(), appLogStore: AppLogStore = AppLogStore()) {
        self.service = service
        self.appLogStore = appLogStore
    }

    func refreshDevices() {
        refreshDevices(showLog: true)
    }

    func startAutoRefresh() {
        guard refreshTimer == nil else { return }

        let timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshDevices(showLog: false)
            }
        }
        timer.tolerance = 0.2
        refreshTimer = timer
        isAutoRefreshing = true
        refreshDevices(showLog: false)
    }

    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        isAutoRefreshing = false
    }

    func prepareFileManager() {
        refreshLocalDirectory()
        refreshRemoteDirectory()
    }

    func setRootModeEnabled(_ isEnabled: Bool) {
        guard isRootModeEnabled != isEnabled else { return }
        isRootModeEnabled = isEnabled
        remoteCurrentPath = isEnabled ? "/" : "/sdcard"
        selectedRemotePath = ""
        refreshRemoteDirectory()
        appendLog(isEnabled ? "[文件管理] 已开启 Root 浏览模式" : "[文件管理] 已关闭 Root 浏览模式")
    }

    func pickLocalDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "打开"

        if panel.runModal() == .OK, let url = panel.url {
            localCurrentPath = url.path
            refreshLocalDirectory()
        }
    }

    func pickApkFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.init(filenameExtension: "apk")!]
        panel.prompt = "选择 APK"

        if panel.runModal() == .OK, let url = panel.url {
            apkPath = url.path
            appendLog("[安装] 已选择 APK：\(url.lastPathComponent)")
        }
    }

    func refreshLocalDirectory() {
        do {
            localEntries = try loadLocalEntries(path: localCurrentPath)
            if !selectedLocalPath.isEmpty && localEntries.first(where: { $0.path == selectedLocalPath }) == nil {
                selectedLocalPath = ""
            }
        } catch {
            appendLog("[文件管理] 本地目录读取失败：\(error.localizedDescription)")
        }
    }

    func refreshRemoteDirectory() {
        do {
            remoteEntries = try service.listRemoteDirectory(path: remoteCurrentPath, asRoot: isRootModeEnabled)
            if !selectedRemotePath.isEmpty && remoteEntries.first(where: { $0.path == selectedRemotePath }) == nil {
                selectedRemotePath = ""
            }
        } catch {
            appendLog("[文件管理] 设备目录读取失败：\(error.localizedDescription)")
        }
    }

    func openLocalParent() {
        let url = URL(fileURLWithPath: localCurrentPath)
        let parent = url.deletingLastPathComponent().path
        guard parent != localCurrentPath else { return }
        localCurrentPath = parent
        selectedLocalPath = ""
        refreshLocalDirectory()
    }

    func openRemoteParent() {
        guard remoteCurrentPath != "/" else { return }
        let parent = (remoteCurrentPath as NSString).deletingLastPathComponent
        remoteCurrentPath = parent.isEmpty ? "/" : parent
        selectedRemotePath = ""
        refreshRemoteDirectory()
    }

    func openLocalDirectory(_ entry: ADBFileEntry) {
        guard entry.isDirectory else { return }
        localCurrentPath = entry.path
        selectedLocalPath = ""
        refreshLocalDirectory()
    }

    func openRemoteDirectory(_ entry: ADBFileEntry) {
        guard entry.isDirectory else { return }
        remoteCurrentPath = entry.path
        selectedRemotePath = ""
        refreshRemoteDirectory()
    }

    func selectLocalEntry(_ entry: ADBFileEntry) {
        selectedLocalPath = entry.path
    }

    func selectRemoteEntry(_ entry: ADBFileEntry) {
        selectedRemotePath = entry.path
    }

    func pushSelected() {
        guard canPushSelected else { return }
        pushLocalPath = selectedLocalPath
        pushRemotePath = joinRemotePath(base: remoteCurrentPath, name: (selectedLocalPath as NSString).lastPathComponent)
        pushFile()
        refreshRemoteDirectory()
    }

    func pullSelected() {
        guard canPullSelected else { return }
        pullRemotePath = selectedRemotePath
        pullLocalPath = joinLocalPath(base: localCurrentPath, name: (selectedRemotePath as NSString).lastPathComponent)
        pullFile()
        refreshLocalDirectory()
    }

    func selectDevice(_ device: DeviceInfo) {
        selectedDevice = device
        service.selectedSerial = device.serial == "-" ? nil : device.serial
        appendLog("[设备] 已切换：\(device.serial)（\(device.model)）")
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

    private func refreshDevices(showLog: Bool) {
        do {
            let list = try service.listDevices()
            devices = list.devices

            if let matched = list.devices.first(where: { $0.serial == selectedDevice.serial }) {
                selectedDevice = matched
            } else {
                selectedDevice = list.devices.first ?? .disconnected
            }
            service.selectedSerial = selectedDevice.serial == "-" ? nil : selectedDevice.serial

            if showLog {
                appendLog("[设备] 刷新完成：共 \(list.devices.count) 台")
            }
        } catch {
            if showLog {
                appendLog("[设备] 刷新失败：\(error.localizedDescription)")
            }
        }
    }

    private func loadLocalEntries(path: String) throws -> [ADBFileEntry] {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let urls = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: path), includingPropertiesForKeys: keys, options: [.skipsHiddenFiles])

        return urls.map { url in
            let values = try? url.resourceValues(forKeys: Set(keys))
            let isDirectory = values?.isDirectory ?? false
            return ADBFileEntry(path: url.path, name: url.lastPathComponent, isDirectory: isDirectory)
        }
        .sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory && !rhs.isDirectory
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private func joinRemotePath(base: String, name: String) -> String {
        if base == "/" {
            return "/\(name)"
        }
        return base.hasSuffix("/") ? base + name : base + "/" + name
    }

    private func joinLocalPath(base: String, name: String) -> String {
        URL(fileURLWithPath: base).appendingPathComponent(name).path
    }

    private func appendLog(_ entry: String) {
        logs = logs.isEmpty ? entry : logs + "\n\n" + entry
        appLogStore.append(source: "ADB", message: entry)
    }
}
