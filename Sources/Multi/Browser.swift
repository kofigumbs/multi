import WebKit

/*
 * WebKit UI wrappers
 */
class Browser: NSObject {
    let title: String
    private let webView: WKWebView

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

    @available(macOS 10.13, *)
    private static func setupBlocklist(for webView: WKWebView) {
        guard let path = Bundle.main.path(forResource: "blocklist", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = String(data: data, encoding: .utf8) else {
            return
        }
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: json.lowercased()) { (rules, error) in
            rules.map { webView.configuration.userContentController.add($0) }
        }
    }

    private init(_ title: String) {
        self.title = title
        self.webView = WKWebView(frame: Browser.window.frame)
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView.bridgeNotifications()
        webView.autoresizesSubviews = true
        webView.navigationDelegate = ExternalLink.singleton
        if #available(macOS 10.13, *) {
            webView.customUserAgent = Browser.USER_AGENT
            Browser.setupBlocklist(for: webView)
        }
    }

    convenience init(_ title: String, url: URL) {
        self.init(title)
        self.webView.load(URLRequest(url: url))
    }

    convenience init(_ title: String, html: String) {
        self.init(title)
        self.webView.loadHTMLString(html, baseURL: nil)
    }

    @objc func view(_: Any? = nil) {
        Browser.window.contentView = webView
        webView.lockFocus()
    }
}
