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
        guard let createMacApp = Bundle.Multi.main?.url(forResource: "create-mac-app", withExtension: nil),
              let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first,
              let tmp = try? FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: desktop, create: true).appendingPathComponent("create-mac-app"),
              let script = """
                  #!/usr/bin/env bash
                  export MULTI_APP_NAME=\(escaped(name))
                  export MULTI_ICON_PATH=\(escaped(icon.selected?.path ?? ""))
                  export MULTI_JSON_CONFIG=\(escaped(json))
                  export MULTI_OVERWRITE=\(escaped(overwrite ? "1" : "0"))
                  export MULTI_REPLACE_PID=\(escaped("\(ProcessInfo.processInfo.processIdentifier)"))
                  \(createMacApp.path) || read -p "Press Enter to exit ... "
                  """.data(using: .utf8),
              FileManager.default.createFile(
                  atPath: tmp.path,
                  contents: script,
                  attributes: [ FileAttributeKey.posixPermissions: 0o777 as Any ]) else {
            fail("Cannot allocate configuration script.")
            return
        }
        let process = Process()
        process.arguments = [ "open", "-a", "Terminal", tmp.path ]
        process.execute()
    }

    private func fail(_ reason: String) {
        let alert = NSAlert()
        alert.messageText = "Multi was unable to create your app"
        alert.informativeText = reason
        alert.alertStyle = .critical
        alert.runModal()
    }

    private func escaped(_ string: String) -> String {
        // Escape tricky characters using `String.init(reflecting:)` then
        // replace the enclosing `""` with `$''`.
        // <https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html>
        return "$'\(String(reflecting: string).dropFirst().dropLast())'"
    }
}
