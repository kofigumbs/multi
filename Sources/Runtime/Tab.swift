import Shared
import WebKit

class Tab: NSObject {
    let title: String
    let basicAuthUser: String
    let basicAuthPassword: String
    let webView: WKWebView
    let window: NSWindow

    // Would be nice to derive this from NSUserNotificationCenter.deliveredNotifications,
    // but it seems like this doesn't automatically clear closed notifications.
    // Also: https://stackoverflow.com/a/64012633
    var badgeCount: Int = 0

    init(title: String, url: URL, customCss: [URL], customJs: [URL], customCookie: [Config.Schema.Cookie], basicAuthUser: String, basicAuthPassword: String, userAgent: String?) {
        let configuration = WKWebViewConfiguration()
        Browser.global.customCss(configuration, urls: customCss)
        Browser.global.customJs(configuration, urls: customJs)
        Browser.global.customCookie(configuration, cookies: customCookie)
        configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsMagnification = true
        webView.autoresizesSubviews = true
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = Browser.global
        webView.customUserAgent = userAgent

        self.title = title
        self.basicAuthUser = basicAuthUser
        self.basicAuthPassword = basicAuthPassword
        self.window = Browser.window(title: title, webView: webView)
        super.init()
        webView.navigationDelegate = self

        if let script = Bundle.multi?.url(forResource: "notification", withExtension: "js"),
           let source = try? String(contentsOf: script) {
            configuration.userContentController.addUserScript(
                WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            )
            configuration.userContentController.add(self, name: "notify")
        }

        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
            rules.map { configuration.userContentController.add($0) }
            self.webView.load(URLRequest(url: url))
        }
    }

    @objc func view(_: Any? = nil) {
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)
    }
}
