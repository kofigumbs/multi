import SwiftUI
import UserNotifications
import WebKit
import MultiSettings

struct TabView: View {
    struct Error: Swift.Error {
        let message: String
    }

    let tab: Config.Tab
    let openExternal: OpenExternal
    let onPresent: (NSWindow) -> Void

    var customCss: [WKUserScript] {
        tab.customCss.compactMap({ try? Data(contentsOf: $0).base64EncodedString() }).map { css in
            WKUserScript(
                source: """
                document.documentElement.prepend(
                    Object.assign(document.createElement("style"), { innerText: atob("\(css)") })
                )
                """,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
        }
    }

    var customJs: [WKUserScript] {
        tab.customJs.compactMap({ try? String(contentsOf: $0) }).map { js in
            WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        }
    }

    var notificationPolyfill: [WKUserScript] {
        guard let url = Bundle.multi?.url(forResource: "notification", withExtension: "js"),
              let js = try? String(contentsOf: url) else {
            return []
        }
        return [WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)]
    }

    var cookies: [HTTPCookie] {
        tab.customCookies.compactMap { cookie in
            let properties: [HTTPCookiePropertyKey: Any?] = [
                .name: cookie.name,
                .path: cookie.path,
                .value: cookie.value,
                .comment: cookie.comment,
                .commentURL: cookie.commentURL,
                .discard: cookie.discard,
                .domain: cookie.domain,
                .expires: cookie.expires,
                .maximumAge: cookie.maximumAge,
                .originURL: cookie.originURL,
                .port: cookie.port,
                .secure: cookie.secure,
                .version: cookie.version,
            ]
            return HTTPCookie(properties: properties.compactMapValues { $0 })
        }
    }

    var body: some View {
        ContentView { webView in
            onPresent(webView.window!)
            webView.load(URLRequest(url: tab.url))
        }
            .with(
                userAgent: tab.userAgent,
                ui: TabViewUIDelegate(openExternal),
                navigation: TabViewNavigationDelegate(tab, openExternal),
                scripts: customCss + customJs + notificationPolyfill,
                cookies: cookies,
                handlers: [
                    "notificationRequest": notificationRequest,
                    "notificationShow": notificationShow,
                    "notificationClose": notificationClose,
                ]
            )
            .navigationTitle(tab.title)
    }

    func notificationRequest(_: NSObject) async throws {
        guard try await UNUserNotificationCenter.current().requestAuthorization() else {
            throw Error(message: "Notification permission denied")
        }
    }

    func notificationShow(message: NSObject) async throws {
        guard let tag = message.value(forKey: "tag") as? String else {
            throw Error(message: "Notification tag is required")
        }
        let content = UNMutableNotificationContent()
        content.title = message.value(forKey: "title") as? String ?? ""
        content.body = message.value(forKey: "body") as? String ?? ""
        try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: tag, content: content, trigger: nil))
    }

    func notificationClose(message: NSObject) async throws {
        guard let tag = message.value(forKey: "tag") as? String else {
            throw Error(message: "Notification tag is required")
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [tag])
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
        let field = NSTextField(string: defaultText ?? "")
        field.frame = NSRect(x: alert.window.contentLayoutRect.minX, y: field.frame.minY, width: alert.window.contentLayoutRect.width, height: field.frame.height)
        alert.accessoryView = field
        alert.messageText = runJavaScriptTextInputPanelWithPrompt
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: webView.window!) { response in completionHandler(response == .alertFirstButtonReturn ? field.stringValue : nil) }
        alert.window.makeFirstResponder(field)
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
        if decidePolicyFor.targetFrame != nil || decidePolicyFor.request.url?.scheme == "about" {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
            _ = decidePolicyFor.request.url.map(openExternal.callAsFunction)
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            completionHandler(.useCredential, URLCredential(user: tab.basicAuthUser, password: tab.basicAuthPassword, persistence: .forSession))
        }
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
