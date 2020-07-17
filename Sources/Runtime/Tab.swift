import WebKit

class Tab: NSObject {
    let title: String
    let webView: WKWebView

    init(title: String, url: URL, `private`: Bool, blocklist: Bool) {
        let configuration = WKWebViewConfiguration()
        let script = WKUserScript(source: Browser.JS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(Browser.global, name: "multi")
        if `private` {
            configuration.websiteDataStore = .nonPersistent()
        }
        if blocklist, #available(macOS 10.13, *) {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
                rules.map { configuration.userContentController.add($0) }
            }
        }

        self.title = title
        self.webView = WKWebView(frame: Browser.window.frame, configuration: configuration)
        webView.enableDevelop()
        webView.allowsMagnification = true
        webView.autoresizesSubviews = true
        webView.uiDelegate = Browser.global
        webView.navigationDelegate = Browser.global
        if #available(macOS 10.13, *) {
            webView.customUserAgent = Browser.userAgent
        }

        webView.load(URLRequest(url: url))
    }

    @objc func view(_: Any? = nil) {
        Browser.window.contentView = webView
        webView.lockFocus()
    }
}
