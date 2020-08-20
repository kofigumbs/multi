import WebKit

class Icon: NSObject, WKScriptMessageHandler {
    var selected: URL? = nil

    public func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["png", "icns"]
        openPanel.beginSheetModal(for: Preferences.window) { (result) in
            if let url = openPanel.url,
                   result == NSApplication.ModalResponse.OK {
                self.select(url, message.webView!)
            }
        }
    }

    func select(_ url: URL, _ webView: WKWebView) {
        self.selected = url
        webView.evaluateJavaScript("document.getElementById('path').innerText = '\(url.lastPathComponent)'")
    }
}
