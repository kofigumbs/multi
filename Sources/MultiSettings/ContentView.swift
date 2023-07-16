import AppKit
import SwiftUI
import WebKit

public struct ContentView: View, NSViewRepresentable {
    private var userAgent: String?
    private var ui: WKUIDelegate?
    private var navigation: WKNavigationDelegate?
    private var scripts: [WKUserScript] = []
    private var cookies: [HTTPCookie] = []
    private var delegate = ContentViewDelegate()
    private let onPresent: (WKWebView) -> Void

    public init(onPresent: @escaping (WKWebView) -> Void) {
        self.onPresent = onPresent
    }

    public func with(
        userAgent: String? = nil,
        ui: WKUIDelegate? = nil,
        navigation: WKNavigationDelegate? = nil,
        scripts: [WKUserScript] = [],
        cookies: [HTTPCookie] = [],
        handlers: [String: (NSObject) async throws -> Any] = [:]
    ) -> ContentView {
        var this = self
        this.userAgent = userAgent
        this.ui = ui
        this.navigation = navigation
        this.scripts = scripts
        this.cookies = cookies
        this.delegate.handlers = handlers
        return this
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

fileprivate class ContentViewDelegate: NSObject, WKScriptMessageHandlerWithReply {
    var handlers = [String: (NSObject) async throws -> Any]()

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
        guard let handler = handlers[message.name] else {
            return (nil, "NoMessageHandler")
        }
        do {
            let result = try await handler(message.body as? NSObject ?? NSNull())
            return (result is Void ? nil : result, nil)
        }
        catch {
            return (nil, String(describing: error))
        }
    }
}
