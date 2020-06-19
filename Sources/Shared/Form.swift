import WebKit

class Form: NSObject, WKScriptMessageHandler {
    typealias Build = (Archive) -> () throws -> ()

    let icon = Icon()
    private let build: Build

    init(_ build: @escaping Build) {
        self.build = build
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let body = didReceive.body as? NSObject,
              let name = body.value(forKey: "name") as? String,
              let json = body.value(forKey: "json") as? String,
              let config = json.data(using: .utf8) else {
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
        guard let stub = Bundle.Multi.main?.url(forResource: "Stub", withExtension: nil),
              let plistTemplate = Bundle.Multi.main?.url(forResource: "Stub", withExtension: "plist"),
              let plist = try? String(contentsOf: plistTemplate)
                  .replacingOccurrences(of: "{{name}}", with: name)
                  .replacingOccurrences(of: "{{id}}", with: name.replacingOccurrences(of: "[^a-zA-Z0-9.]", with: "-", options: [.regularExpression]))
                  .data(using: .utf8) else {
            fail("Multi.app is missing essential files.")
            return
        }
        do {
            let archive = Archive(name: name, app: app, stub: stub, plist: plist, config: config)
            try build(archive)()
            try icon.createSet(resources: archive.resources)
            NSApp.terminate(nil)
            NSWorkspace.shared.open(archive.app)
        } catch Archive.Error.alreadyExists {
            fail("An app with that name already exists.")
        } catch Archive.Error.cannotWriteFile(let url) {
            fail("Cannot write file: \(url.path)")
        } catch let error {
            fail(error.localizedDescription)
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
