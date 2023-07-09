import SwiftUI
import WebKit
import MultiSettings

struct TabView: View {
    let tab: Config.Tab
    let onAdd: (NSWindow) -> Void

    var body: some View {
        ContentView(scripts: [], handlers: [:]) { webView in
            // let configuration = WKWebViewConfiguration()
            // Browser.global.customCss(configuration, urls: customCss)
            // Browser.global.customJs(configuration, urls: customJs)
            // configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
            // configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

            // self.webView = WKWebView(frame: .zero, configuration: configuration)
            // webView.allowsMagnification = true
            // webView.autoresizesSubviews = true
            // webView.allowsBackForwardNavigationGestures = true
            // webView.uiDelegate = Browser.global
            // webView.customUserAgent = userAgent

            // self.title = title
            // self.basicAuthUser = basicAuthUser
            // self.basicAuthPassword = basicAuthPassword
            // self.window = Browser.window(title: title, webView: webView)
            // super.init()
            // webView.navigationDelegate = self

            // if let script = Bundle.multi?.url(forResource: "notification", withExtension: "js"),
            //    let source = try? String(contentsOf: script) {
            //     configuration.userContentController.addUserScript(
            //         WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            //     )
            //     configuration.userContentController.add(self, name: "notify")
            // }

            // WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "blocklist", encodedContentRuleList: Browser.blocklist) { (rules, error) in
            //     rules.map { configuration.userContentController.add($0) }
            //     self.webView.load(URLRequest(url: url))
            // }
            DispatchQueue.main.async {
                onAdd(webView.window!)
            }
            webView.load(URLRequest(url: tab.url))
        }
            .navigationTitle(tab.title)
    }
}
