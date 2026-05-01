import Foundation

struct ADBDeviceList {
    let devices: [DeviceInfo]
}

enum ADBServiceError: Error {
    case executableMissing
    case commandFailed(String)
}

final class ADBService {
    private let runner: ProcessRunner

    init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
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

    private func run(arguments: [String]) throws -> String {
        guard let executable = ADBExecutableLocator.locate() else {
            throw ADBServiceError.executableMissing
        }

        let result = try runner.run(executable: executable, arguments: arguments)
        guard result.exitCode == 0 else {
            throw ADBServiceError.commandFailed(result.output)
        }

        return result.output
    }
}
