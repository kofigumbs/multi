import WebKit

class Form: NSObject, WKScriptMessageHandler {
    let icon = Icon()

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let body = didReceive.body as? NSObject,
              let name = body.value(forKey: "name") as? String,
              let json = body.value(forKey: "json") as? String else {
            fail("Cannot load your configuration.")
            return
        }
        guard let createMacApp = Bundle.Multi.main?.url(forResource: "create-mac-app", withExtension: nil),
              let _ = try? Process.execute(createMacApp, arguments: [ name, icon.selected?.absoluteString ?? "", json ]) else {
            fail("") // TODO
            return
        }
        exit(0)
    }

    private func fail(_ reason: String) {
        let alert = NSAlert()
        alert.messageText = "Multi was unable to create your app"
        alert.informativeText = reason
        alert.alertStyle = .critical
        alert.runModal()
    }
}
