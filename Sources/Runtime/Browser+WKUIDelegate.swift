import Shared
import WebKit

extension Browser: WKUIDelegate {
    func webView(_: WKWebView, createWebViewWith: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        _ = navigationAction.request.url.map(NSWorkspace.shared.open)
        return WKWebView()
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = runJavaScriptAlertPanelWithMessage
        alert.beginSheetModal(for: Browser.window) { _ in completionHandler() }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage: String, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = runJavaScriptConfirmPanelWithMessage
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: Browser.window) { response in completionHandler(response == .alertFirstButtonReturn) }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt: String, defaultText: String?, initiatedByFrame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = NSAlert()
        let textField = NSTextField(frame: Program.messageFrame)
        textField.stringValue = defaultText ?? ""
        alert.accessoryView = textField
        alert.messageText = runJavaScriptTextInputPanelWithPrompt
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: Browser.window) { response in completionHandler(response == .alertFirstButtonReturn ? textField.stringValue : nil) }
        alert.window.makeFirstResponder(textField)
    }

    @available(macOS 10.12, *)
    func webView(_ webView: WKWebView, runOpenPanelWith: WKOpenPanelParameters, initiatedByFrame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        if #available(macOS 10.13.4, *) {
            openPanel.canChooseDirectories = runOpenPanelWith.allowsDirectories
        }
        openPanel.allowsMultipleSelection = runOpenPanelWith.allowsMultipleSelection
        openPanel.beginSheetModal(for: Browser.window) { _ in completionHandler(openPanel.urls) }
    }
}
