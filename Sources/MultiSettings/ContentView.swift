import AppKit
import SwiftUI
import WebKit

public struct ContentView: View, NSViewRepresentable {
    private let delegate = ContentViewDelegate()
    private let onAppear: (WKWebView) -> Void

    public init(handlers: [String: (NSObject) async throws -> Any], onAppear: @escaping (WKWebView) -> Void) {
        self.delegate.handlers = handlers
        self.onAppear = onAppear
    }

    public func makeNSView(context: NSViewRepresentableContext<ContentView>) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.setValue(false, forKey: "drawsBackground")
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView.configuration.userContentController.addScriptMessageHandler(delegate, contentWorld: .page, name: "app")
        onAppear(webView)
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
        guard let arguments = message.body as? NSObject,
              let channel = arguments.value(forKey: "channel") as? String,
              let handler = handlers[channel] else {
            return (nil, "NoMessageHandler")
        }
        do {
            return (try await handler(arguments), nil)
        }
        catch {
            return (nil, String(describing: error))
        }
    }
}
