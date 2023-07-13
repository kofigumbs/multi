import AppKit
import SwiftUI
import WebKit

public struct ContentView: View, NSViewRepresentable {
    private let scripts: [WKUserScript]
    private let delegate = ContentViewDelegate()
    private let onAppear: (WKWebView) -> Void

    public init(scripts: [WKUserScript], handlers: [String: (NSObject) async throws -> Any], onAppear: @escaping (WKWebView) -> Void) {
        self.scripts = scripts
        self.delegate.handlers = handlers
        self.onAppear = onAppear
    }

    public func makeNSView(context: NSViewRepresentableContext<ContentView>) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "fullScreenEnabled")
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        for script in scripts {
            configuration.userContentController.addUserScript(script)
        }
        for handler in delegate.handlers {
            configuration.userContentController.addScriptMessageHandler(delegate, contentWorld: .page, name: handler.key)
        }
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsMagnification = true
        webView.autoresizesSubviews = true
        webView.allowsBackForwardNavigationGestures = true
        webView.setValue(false, forKey: "drawsBackground")
        DispatchQueue.main.async {
            onAppear(webView)
            webView.window!.contentView = webView
        }
        return webView
    }

    public func updateNSView(_ webView: WKWebView, context: NSViewRepresentableContext<ContentView>) {
    }
}

fileprivate class ContentViewDelegate: NSObject {
    var handlers = [String: (NSObject) async throws -> Any]()
}

extension ContentViewDelegate: WKScriptMessageHandlerWithReply {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
        guard let handler = handlers[message.name] else {
            return (nil, "NoMessageHandler")
        }
        do {
            return (try await handler(message.body as? NSObject ?? NSNull()), nil)
        }
        catch {
            return (nil, String(describing: error))
        }
    }
}
