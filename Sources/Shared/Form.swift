import WebKit

class Form: NSObject, WKScriptMessageHandler {
    let icon = Icon()

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let body = didReceive.body as? NSObject,
              let name = body.value(forKey: "name") as? String,
              let json = body.value(forKey: "json"),
              let config = try? JSONSerialization.data(withJSONObject: json) else {
            fail("Cannot load your configuration.")
            return
        }
        guard let app = try? FileManager.default
                  .url(for: .applicationDirectory, in: .localDomainMask, appropriateFor: nil, create: false)
                  .appendingPathComponent(name, isDirectory: true)
                  .appendingPathExtension("app") else {
            fail("Cannot access your Applications directory.")
            return
        }
        guard let stub = Bundle.main.url(forResource: "Stub", withExtension: nil),
              let plistTemplate = Bundle.main.url(forResource: "Stub", withExtension: "plist"),
              let plistData = try? String(contentsOf: plistTemplate)
                  .replacingOccurrences(of: "{{name}}", with: name)
                  .replacingOccurrences(of: "{{id}}", with: name.replacingOccurrences(of: "[^a-zA-Z0-9.\\-]", with: "-", options: [.regularExpression]))
                  .data(using: .utf8) else {
            fail("Multi.app is missing essential files.")
            return
        }
        do {
            let contents = app.appendingPathComponent("Contents", isDirectory: true)
            let resources = contents.appendingPathComponent("Resources", isDirectory: true)
            if try createDirectories(app: app, resources: resources) {
                try FileManager.default.copyItem(at: stub, to: app.appendingPathComponent("Stub"))
                FileManager.default.createFile(atPath: contents.appendingPathComponent("Info.plist").path, contents: plistData)
                FileManager.default.createFile(atPath: resources.appendingPathComponent("config.json").path, contents: config)
                try icon.createSet(resources: resources)
                NSWorkspace.shared.open(app)
                exit(0)
            }
        } catch let error {
            fail(error.localizedDescription)
        }
    }

    private func createDirectories(app: URL, resources: URL) throws -> Bool {
        if !FileManager.default.fileExists(atPath: app.path) {
            try FileManager.default.createDirectory(
                at: app,
                withIntermediateDirectories: false,
                attributes: [FileAttributeKey.posixPermissions: 0o777 as Any]
            )
            try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
            return true
        } else if Bundle(url: app)?.object(forInfoDictionaryKey: "MultiApp") as? Bool == true {
            return confirm("Are you sure you want to overwrite your Multi app?") == .OK
        } else {
            fail("An app with that name already exists.")
            return false
        }
    }

    private func fail(_ reason: String) {
        let alert = NSAlert()
        alert.messageText = "Multi was unable to create your app"
        alert.informativeText = reason
        alert.alertStyle = .critical
        alert.runModal()
    }

    private func confirm(_ prompt: String) -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = prompt
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        return alert.runModal()
    }
}
