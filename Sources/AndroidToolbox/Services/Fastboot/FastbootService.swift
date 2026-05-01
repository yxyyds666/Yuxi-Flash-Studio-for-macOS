import Foundation

enum FastbootServiceError: Error {
    case executableMissing
    case commandFailed(String)
}

final class FastbootService {
    private let runner: ProcessRunner

    init(runner: ProcessRunner = ProcessRunner()) {
        self.runner = runner
    }

    func listDevices() throws -> [DeviceInfo] {
        let output = try run(arguments: ["devices"])
        return FastbootParser.parseDevices(from: output)
    }

    func getVar(_ key: String) throws -> String {
        try run(arguments: ["getvar", key])
    }

    func rebootBootloader() throws -> String {
        try run(arguments: ["reboot-bootloader"])
    }

    func reboot() throws -> String {
        try run(arguments: ["reboot"])
    }

    private func run(arguments: [String]) throws -> String {
        guard let executable = FastbootExecutableLocator.locate() else {
            throw FastbootServiceError.executableMissing
        }

        let result = try runner.run(executable: executable, arguments: arguments)
        guard result.exitCode == 0 else {
            throw FastbootServiceError.commandFailed(result.output)
        }

        return result.output
    }
}
