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
            Program.alert(message: "Cannot load your configuration.")
            return
        }
        guard let createMacApp = Bundle.multi?.url(forResource: "create-mac-app", withExtension: nil) else {
            Program.alert(message: "Cannot find create-mac-app.")
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
                Program.alert(message: output ?? "create-mac-app exited with code \(process.terminationStatus)")
            }
        }

        guard let _ = try? process.run() else {
            Program.alert(message: "Cannot execute create-mac-app.")
            return
        }
    }
}
