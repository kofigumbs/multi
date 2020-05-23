import WebKit

/*
 * WebKit UI wrappers
 */
class Browser {
    let title: String
    private let webview: WKWebView

    // Fake a more popular browser to circumvent UA-sniffing
    private static let USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15"

    private static let window: NSWindow = {
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

    private init(_ title: String) {
        self.title = title
        self.webview = WKWebView(frame: Browser.window.frame)
        webview.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webview.bridgeNotifications()
        webview.autoresizesSubviews = true
        webview.autoresizingMask = [.width, .height]
        if #available(macOS 10.13, *) {
            webview.customUserAgent = Browser.USER_AGENT
        }
    }

    convenience init(_ title: String, url: URL) {
        self.init(title)
        self.webview.load(URLRequest(url: url))
    }

    convenience init(_ title: String, html: String) {
        self.init(title)
        self.webview.loadHTMLString(html, baseURL: nil)
    }

    @objc func view(_: Any? = nil) {
        Browser.window.contentView = webview
        webview.lockFocus()
    }
}
