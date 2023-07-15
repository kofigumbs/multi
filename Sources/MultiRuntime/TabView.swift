import SwiftUI
import WebKit
import MultiSettings

struct TabView: View {
    let config: Config
    let index: Int
    let onAppear: (NSWindow) -> Void

    var tab: Config.Tab {
        config.tabs[index]
    }

    var openExternal: OpenExternal {
        OpenExternal(config: config)
    }

    var body: some View {
        ContentView { webView in
            onAppear(webView.window!)
            webView.load(URLRequest(url: tab.url))
        }
            .with(
                userAgent: tab.userAgent,
                ui: TabViewUIDelegate(openExternal),
                navigation: TabViewNavigationDelegate(tab, openExternal)
                /// TODO scripts: notifications, custom JS/CSS
                /// TODO cookies
                /// TODO handlers: notifications
            )
            .navigationTitle(tab.title)
    }
}

fileprivate class TabViewUIDelegate: NSObject, WKUIDelegate {
    let openExternal: OpenExternal

    init(_ openExternal: OpenExternal) {
        self.openExternal = openExternal
    }

    func webView(_: WKWebView, createWebViewWith: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        _ = navigationAction.request.url.map(openExternal.callAsFunction)
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = runJavaScriptAlertPanelWithMessage
        alert.beginSheetModal(for: webView.window!) { _ in completionHandler() }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = runJavaScriptConfirmPanelWithMessage
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: webView.window!) { response in completionHandler(response == .alertFirstButtonReturn) }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt: String, defaultText: String?, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = NSAlert()
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 224, height: 21))
        textField.stringValue = defaultText ?? ""
        alert.accessoryView = textField
        alert.messageText = runJavaScriptTextInputPanelWithPrompt
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: webView.window!) { response in completionHandler(response == .alertFirstButtonReturn ? textField.stringValue : nil) }
        alert.window.makeFirstResponder(textField)
    }

    func webView(_ webView: WKWebView, runOpenPanelWith: WKOpenPanelParameters, initiatedByFrame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = runOpenPanelWith.allowsDirectories
        openPanel.allowsMultipleSelection = runOpenPanelWith.allowsMultipleSelection
        openPanel.beginSheetModal(for: webView.window!) { _ in completionHandler(openPanel.urls) }
    }
}

fileprivate class TabViewNavigationDelegate: NSObject, WKNavigationDelegate {
    let tab: Config.Tab
    let openExternal: OpenExternal

    init(_ tab: Config.Tab, _ openExternal: OpenExternal) {
        self.tab = tab
        self.openExternal = openExternal
    }

    func webView(_: WKWebView, decidePolicyFor: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) -> () {
        switch decidePolicyFor.targetFrame {
            case .some(_):
                decisionHandler(.allow)
            case .none:
                decisionHandler(.cancel)
                _ = decidePolicyFor.request.url.map(openExternal.callAsFunction)
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic,
              let basicAuthUser = tab.basicAuthUser,
              let basicAuthPassword = tab.basicAuthPassword else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        completionHandler(.useCredential, URLCredential(user: basicAuthUser, password: basicAuthPassword, persistence: .forSession))
    }
}
