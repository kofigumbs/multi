import WebKit

class Tab: NSObject {
    let title: String
    let webView: WKWebView

    private init(_ title: String) {
        let webView = WKWebView(frame: Browser.window.frame)
        self.title = title
        self.webView = webView

        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView.autoresizesSubviews = true
        webView.navigationDelegate = Browser.global

        let script = WKUserScript(source: Browser.JS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.configuration.userContentController.add(Browser.global, name: "multi.js")

        if #available(macOS 10.13, *) {
            webView.customUserAgent = Browser.userAgent
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
                rules.map { webView.configuration.userContentController.add($0) }
            }
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
