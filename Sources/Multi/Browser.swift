import WebKit

class Browser: NSObject {
    static let global = Browser()

    static let title = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Multi"

    // Fake a more popular browser to circumvent UA-sniffing
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"

    static let window: NSWindow = {
        let window = NSWindow(
            contentRect: NSScreen.main!.frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false
        )
        window.cascadeTopLeft(from: .zero)
        window.title = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Multi"
        window.makeKeyAndOrderFront(nil)
        return window
    }()
}
