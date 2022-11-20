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
        guard let createMacApp = Bundle.multi?.url(forResource: "create-mac-app", withExtension: nil) else {
            fail("Cannot find create-mac-app.")
            return
        }

        let process = Process()
        process.environment = [
            "MULTI_APP_NAME": name,
            "MULTI_ICON_PATH": icon.selected?.path ?? "",
            "MULTI_JSON_CONFIG": json,
            "MULTI_OVERWRITE": overwrite ? "1" : "0",
            "MULTI_RELAUNCH_PID": "\(ProcessInfo.processInfo.processIdentifier)",
            "MULTI_UI": "1",
        ]
        process.executableURL = createMacApp

        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe
        process.terminationHandler = { process in
            if process.terminationStatus != 0 {
                let output = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8)
                self.fail(output ?? "create-mac-app exited with code \(process.terminationStatus)")
            }
        }

        try! process.run()
    }

    private func fail(_ reason: String) {
        let alert = NSAlert()
        alert.messageText = "Multi run into an issue creating your app"
        alert.informativeText = reason
        alert.alertStyle = .critical
        alert.runModal()
    }
}
