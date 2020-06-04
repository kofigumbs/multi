import WebKit

class Form: NSObject, WKScriptMessageHandler {
    let icon = Icon()

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        let body = didReceive.body as! NSObject
        let name = body.value(forKey: "name") as! String
        let json = body.value(forKey: "json") as Any
        let app = URL(fileURLWithPath: "/Applications", isDirectory: true)
            .appendingPathComponent(name, isDirectory: true)
            .appendingPathExtension("app")
        let contents = app.appendingPathComponent("Contents", isDirectory: true)
        let resources = contents.appendingPathComponent("Resources", isDirectory: true)
        // TODO check whether app exists
        try! FileManager.default.createDirectory(
            at: app,
            withIntermediateDirectories: false,
            attributes: [FileAttributeKey.posixPermissions: 0o777 as Any]
        )
        try! FileManager.default.createDirectory(
            at: resources,
            withIntermediateDirectories: true
        )
        try! FileManager.default.copyItem(
            at: Bundle.main.url(forResource: "Stub", withExtension: nil)!,
            to: app.appendingPathComponent("Stub")
        )
        FileManager.default.createFile(
            atPath: contents.appendingPathComponent("Info.plist").path,
            contents: try! String(contentsOf: Bundle.main.url(forResource: "Stub", withExtension: "plist")!).replacingOccurrences(of: "{{Stub}}", with: name).data(using: .utf8)!
        )
        FileManager.default.createFile(
            atPath: resources.appendingPathComponent("config.json").path,
            contents: try! JSONSerialization.data(withJSONObject: json)
        )
    }
}
