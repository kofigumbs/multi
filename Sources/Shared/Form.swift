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
              let json = body.value(forKey: "json") as? String,
              let script = Bundle.Multi.main?.url(forResource: "create-mac-app-from-ui", withExtension: nil) else {
            fail("Cannot load your configuration.")
            return
        }
        let process = Process()
        process.environment = [
            "MULTI_APP_NAME": name,
            "MULTI_ICON_PATH": icon.selected?.path ?? "",
            "MULTI_JSON_CONFIG": json,
            "MULTI_OVERWRITE": overwrite ? "1" : "0",
            "MULTI_REPLACE_PID": "\(ProcessInfo.processInfo.processIdentifier)",
        ]
        let pipe = Pipe()
        process.standardError = pipe
        process.execute(script)
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            fail(String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self))
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
