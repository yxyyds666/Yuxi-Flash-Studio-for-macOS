import Foundation

enum ADBExecutableLocator {
    static func locate() -> URL? {
        if let bundled = Bundle.module.url(forResource: "adb", withExtension: nil, subdirectory: "Tools") {
            return bundled
        }

        let fallback = URL(fileURLWithPath: "/usr/bin/adb")
        if FileManager.default.isExecutableFile(atPath: fallback.path) {
            return fallback
        }

        return nil
    }
}
