import WebKit

class Icon: NSObject, WKScriptMessageHandler {
    var url: URL? = nil

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["png"]
        openPanel.beginSheetModal(for: Preferences.window) { (result) in
            if let url = openPanel.url,
                   result == NSApplication.ModalResponse.OK {
                self.url = url
            }
        }
    }
}
