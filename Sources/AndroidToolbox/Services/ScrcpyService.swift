import Foundation

enum ScrcpyServiceError: Error {
    case executableMissing
    case launchFailed(String)
}

final class ScrcpyService {
    private var process: Process?

    var isRunning: Bool {
        process?.isRunning ?? false
    }

    func locate() -> URL? {
        let candidates = [
            "/opt/homebrew/bin/scrcpy",
            "/usr/local/bin/scrcpy",
            "/usr/bin/scrcpy"
        ]

        for candidate in candidates {
            if FileManager.default.isExecutableFile(atPath: candidate) {
                return URL(fileURLWithPath: candidate)
            }
        }

        if let pathValue = ProcessInfo.processInfo.environment["PATH"] {
            for directory in pathValue.split(separator: ":").map(String.init) {
                let candidate = URL(fileURLWithPath: directory).appendingPathComponent("scrcpy").path
                if FileManager.default.isExecutableFile(atPath: candidate) {
                    return URL(fileURLWithPath: candidate)
                }
            }
        }

        return nil
    }

    func start(maxSize: Int? = nil, bitRate: Int? = nil, turnScreenOff: Bool = false) throws {
        guard let executable = locate() else {
            throw ScrcpyServiceError.executableMissing
        }

        var args: [String] = []
        if let maxSize {
            args += ["--max-size", "\(maxSize)"]
        }
        if let bitRate {
            args += ["--bit-rate", "\(bitRate)M"]
        }
        if turnScreenOff {
            args.append("--turn-screen-off")
        }
        args.append("--stay-awake")

        let process = Process()
        process.executableURL = executable
        process.arguments = args

        do {
            try process.run()
            self.process = process
        } catch {
            throw ScrcpyServiceError.launchFailed(error.localizedDescription)
        }
    }

    func stop() {
        process?.terminate()
        process = nil
    }
}
