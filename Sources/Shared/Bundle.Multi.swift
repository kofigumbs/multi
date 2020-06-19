import AppKit

extension Bundle {
    public enum Multi {}
}

extension Bundle.Multi {
    public static let mainIdentifier = "sexy.kofi.multi"
    public static let main = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mainIdentifier).flatMap(Bundle.init)
    public static let stub = CommandLine.arguments.last.flatMap(Bundle.init)
    public static let stubTitle = stub?.object(forInfoDictionaryKey: "CFBundleName") as? String
}
