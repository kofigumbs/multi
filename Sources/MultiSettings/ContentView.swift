import AppKit
import SwiftUI
import WebKit

public struct ContentView: View, NSViewRepresentable {
    private let userAgent: String?
    private let ui: WKUIDelegate?
    private let navigation: WKNavigationDelegate?
    private let scripts: [WKUserScript]
    private let cookies: [HTTPCookie]
    private let onPresent: (WKWebView) -> Void

    private let delegate = ContentViewDelegate()

    public init(
        userAgent: String? = nil,
        ui: WKUIDelegate? = nil,
        navigation: WKNavigationDelegate? = nil,
        scripts: [WKUserScript] = [],
        cookies: [HTTPCookie] = [],
        handlers: [String: (NSObject) async throws -> Any] = [:],
        onPresent: @escaping (WKWebView) -> Void
    ) {
        self.userAgent = userAgent
        self.ui = ui
        self.navigation = navigation
        self.scripts = scripts
        self.cookies = cookies
        self.delegate.handlers = handlers
        self.onPresent = onPresent
    }

    public func makeNSView(context: NSViewRepresentableContext<ContentView>) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        for script in scripts {
            configuration.userContentController.addUserScript(script)
        }
        for cookie in cookies {
            configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
        for handler in delegate.handlers {
            configuration.userContentController.addScriptMessageHandler(delegate, contentWorld: .page, name: handler.key)
        }
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsMagnification = true
        webView.autoresizesSubviews = true
        webView.allowsBackForwardNavigationGestures = true
        webView.setValue(false, forKey: "drawsBackground")
        webView.customUserAgent = userAgent
        webView.uiDelegate = ui
        webView.navigationDelegate = navigation
        DispatchQueue.main.async {
            onPresent(webView)
            webView.window!.contentView = webView
        }
        return webView
    }

    public func updateNSView(_ webView: WKWebView, context: NSViewRepresentableContext<ContentView>) {
    }
}
