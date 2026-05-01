import Foundation

enum FastbootExecutableLocator {
    static func locate() -> URL? {
        if let bundled = Bundle.module.url(forResource: "fastboot", withExtension: nil, subdirectory: "Tools") {
            return bundled
        }

        let fallback = URL(fileURLWithPath: "/usr/bin/fastboot")
        if FileManager.default.isExecutableFile(atPath: fallback.path) {
            return fallback
        }

        return nil
    }
}
