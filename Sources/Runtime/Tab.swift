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

    init(title: String, url: URL, customCss: [URL], customJs: [URL], basicAuthUser: String, basicAuthPassword: String, userAgent: String?) {
        let configuration = WKWebViewConfiguration()
        Browser.global.customCss(configuration, urls: customCss)
        Browser.global.customJs(configuration, urls: customJs)
        configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
            rules.map { configuration.userContentController.add($0) }
        }

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        webView.enableDevelop()
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

        self.notification(configuration)
        webView.load(URLRequest(url: url))
    }

    @objc func view(_: Any? = nil) {
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)
    }
}
