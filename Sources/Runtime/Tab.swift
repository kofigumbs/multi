import WebKit

class Tab: NSObject {
    let title: String
    let webView: WKWebView

    init(title: String, url: URL, customCss: [URL], customJs: [URL]) {
        let configuration = WKWebViewConfiguration()
        Browser.global.notification(configuration)
        Browser.global.customCss(configuration, urls: customCss)
        Browser.global.customJs(configuration, urls: customJs)
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
            rules.map { configuration.userContentController.add($0) }
        }

        self.title = title
        self.webView = WKWebView(frame: Browser.window.frame, configuration: configuration)
        webView.enableDevelop()
        webView.allowsMagnification = true
        webView.autoresizesSubviews = true
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = Browser.global
        webView.navigationDelegate = Browser.global
        webView.customUserAgent = Browser.userAgent
        webView.load(URLRequest(url: url))
    }

    init(license: ()) {
        self.title = "Purchase a license"
        self.webView = WKWebView(frame: Browser.window.frame)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = Browser.global
        webView.configuration.userContentController.add(License.global, name: "license")
        webView.enableDevelop()
        if let url = Bundle.multi?.url(forResource: "license", withExtension: "html"),
           let html = try? String(contentsOf: url) {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    @objc func view(_: Any? = nil) {
        if Config.sideBySide {
            let stack = NSStackView(views: Config.tabs.map { $0.webView })
            stack.spacing = 0
            stack.distribution = .fillEqually
            Browser.window.contentView = stack
        } else {
            Browser.window.contentView = webView
        }
        Browser.selectedTab = self
        Browser.window.makeFirstResponder(webView)
        webView.nextResponder = Browser.global
    }
}
