import Foundation

enum ADBRebootTarget: String {
    case system
    case fastboot
    case bootloader
    case edl
    case recovery
    case sideload
}

struct ADBDeviceList {
    let devices: [DeviceInfo]
}

enum ADBServiceError: Error {
    case executableMissing
    case commandFailed(String)
}

typealias ADBExecutableResolver = () -> URL?

final class ADBService {
    private let runner: any ProcessRunning
    private let resolveExecutable: ADBExecutableResolver

    init(
        runner: any ProcessRunning = ProcessRunner(),
        resolveExecutable: @escaping ADBExecutableResolver = ADBExecutableLocator.locate
    ) {
        self.runner = runner
        self.resolveExecutable = resolveExecutable
    }

    func listDevices() throws -> ADBDeviceList {
        let output = try run(arguments: ["devices", "-l"])
        return ADBDeviceList(devices: ADBParser.parseDevices(from: output))
    }

    func runShell(_ command: String) throws -> String {
        try run(arguments: ["shell", command])
    }

    func install(apkPath: String) throws -> String {
        try run(arguments: ["install", apkPath])
    }

    func pull(remotePath: String, localPath: String) throws -> String {
        try run(arguments: ["pull", remotePath, localPath])
    }

    func push(localPath: String, remotePath: String) throws -> String {
        try run(arguments: ["push", localPath, remotePath])
    }

    func listRemoteDirectory(path: String, asRoot: Bool = false) throws -> [ADBFileEntry] {
        let arguments: [String]
        if asRoot {
            let command = "ls -a -p -- \(shellQuote(path))"
            arguments = ["shell", "su", "-c", command]
        } else {
            arguments = ["shell", "ls", "-a", "-p", "--", path]
        }

        let output = try run(arguments: arguments)
        return parseRemoteEntries(output: output, basePath: path)
    }

    func reboot(_ target: ADBRebootTarget) throws -> String {
        switch target {
        case .system:
            return try run(arguments: ["reboot"])
        case .fastboot, .bootloader, .edl, .recovery, .sideload:
            return try run(arguments: ["reboot", target.rawValue])
        }
    }

    private func parseRemoteEntries(output: String, basePath: String) -> [ADBFileEntry] {
        output
            .split(whereSeparator: \.isNewline)
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { $0 != "." && $0 != ".." }
            .map { line in
                let isDirectory = line.hasSuffix("/")
                let rawName = isDirectory ? String(line.dropLast()) : line
                let path = joinRemotePath(base: basePath, name: rawName)
                return ADBFileEntry(path: path, name: rawName, isDirectory: isDirectory)
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

    private func shellQuote(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private func run(arguments: [String]) throws -> String {
        guard let executable = resolveExecutable() else {
            throw ADBServiceError.executableMissing
        }

        let result = try runner.run(executable: executable, arguments: arguments, timeout: 20)
        guard result.exitCode == 0 else {
            throw ADBServiceError.commandFailed(result.output)
        }

        return result.output
    }
}
