import WebKit

class Form: NSObject, WKScriptMessageHandler {
    let icon = Icon()
    let overwrite: Bool

    init(overwrite: Bool) {
        self.overwrite = overwrite
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let body = didReceive.body as? NSObject,
              let name = body.value(forKey: "name") as? String,
              let json = body.value(forKey: "json") as? String else {
            fail("Cannot load your configuration.")
            return
        }
        if let createMacApp = Bundle.Multi.main?.url(forResource: "create-mac-app", withExtension: nil),
           Script.run(createMacApp, environment: [
               "APP_NAME": name,
               "ICON_PATH": icon.selected?.path ?? "",
               "JSON_CONFIG": json,
               "OVERWRITE": overwrite ? "1" : "0",
               "RELAUNCH_PID": "\(ProcessInfo.processInfo.processIdentifier)",
               "UI": "1",
           ]) {
            fail("Cannot allocate configuration script.")
        }
    }

    private func fail(_ reason: String) {
        let alert = NSAlert()
        alert.messageText = "Multi was unable to create your app"
        alert.informativeText = reason
        alert.alertStyle = .critical
        alert.runModal()
    }
}
