import AppKit

extension Bundle {
    public static let multi =
        NSWorkspace.shared
            .urlForApplication(withBundleIdentifier: "llc.gumbs.multi")
            .flatMap { Bundle(url: $0) }

    public var title: String? {
        self.object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    public var version: String? {
        self.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

}
