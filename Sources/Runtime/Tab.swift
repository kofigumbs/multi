import Shared
import WebKit

class Tab: NSObject {
    let title: String
    let basicAuthUser: String
    let basicAuthPassword: String
    let webView: WKWebView
    let window: NSWindow

    init(title: String, url: URL, customCss: [URL], customJs: [URL], basicAuthUser: String, basicAuthPassword: String) {
        let configuration = WKWebViewConfiguration()
        Browser.global.notification(configuration)
        Browser.global.customCss(configuration, urls: customCss)
        Browser.global.customJs(configuration, urls: customJs)
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
            rules.map { configuration.userContentController.add($0) }
        }

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        webView.enableDevelop()
        webView.allowsMagnification = true
        webView.autoresizesSubviews = true
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = Browser.global
        webView.customUserAgent = Browser.userAgent
        webView.load(URLRequest(url: url))

        self.title = title
        self.basicAuthUser = basicAuthUser
        self.basicAuthPassword = basicAuthPassword
        self.window = Browser.window(title: title, webView: webView)
        super.init()
        webView.navigationDelegate = self
    }

    init(license: ()) {
        self.webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        webView.configuration.userContentController.add(License.global, name: "license")
        webView.enableDevelop()
        if let url = Bundle.multi?.url(forResource: "license", withExtension: "html"),
           let html = try? String(contentsOf: url) {
            webView.loadHTMLString(html, baseURL: nil)
        }

        self.title = "Purchase a license"
        self.basicAuthUser = ""
        self.basicAuthPassword = ""
        self.window = Browser.window(title: title, webView: webView)
        super.init()
        webView.navigationDelegate = self
    }

    @objc func view(_: Any? = nil) {
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)
    }
}
