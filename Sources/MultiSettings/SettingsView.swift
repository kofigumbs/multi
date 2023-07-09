import SwiftUI
import WebKit

public struct SettingsView: View {
    struct Error: Swift.Error {
        let message: String
    }

    private let overwrite: Bool

    public init(overwrite: Bool) {
        self.overwrite = overwrite
    }

    var html: String {
        guard let url = Bundle.multi?.url(forResource: "settings", withExtension: "html"),
              let html = try? String(contentsOf: url) else {
            return """
                <!DOCTYPE html>
                Cannot open <code>settings.html</code>.
            """
        }
        return html
    }

    var scripts: [WKUserScript] {
        guard overwrite,
              let configFile = Bundle.main.url(forResource: "config", withExtension: "json"),
              let configContent = try? String(contentsOf: configFile),
              let name = try? JSONEncoder().encode(Bundle.main.title ?? ""),
              let json = try? JSONEncoder().encode(configContent) else {
            return []
        }
        return [WKUserScript(
            source: """
                document.getElementById("name").value = \(name)
                document.getElementById("json").value = \(json)
                document.getElementById("save").disabled = false
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )]
    }

    public var body: some View {
        ContentView(scripts: scripts, handlers: ["json": json, "save": save]) { webView in
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    func json(message: NSObject) async throws -> Any {
        guard let json = message as? String,
              let data = json.data(using: .utf8) else {
            throw Error(message: "JSON is not UTF8-encoded")
        }
        _ = try JSONDecoder().decode(Config.self, from: data)
        return 0
    }

    func save(message: NSObject) async throws -> Any {
        guard let name = message.value(forKey: "name") as? String,
              let json = message.value(forKey: "json") as? String,
              let createMacApp = Bundle.multi?.url(forResource: "create-mac-app", withExtension: nil) else {
            throw Error(message: "App Name and JSON Config are required to run create-mac-app")
        }
        let task = Task.detached(priority: .userInitiated) {
            let process = Process()
            process.environment = [
                "MULTI_APP_NAME": name,
                "MULTI_ICON_PATH": message.value(forKey: "icon") as? String ?? "",
                "MULTI_JSON_CONFIG": json,
                "MULTI_OVERWRITE": overwrite ? "1" : "0",
                "MULTI_RELAUNCH_PID": "\(ProcessInfo.processInfo.processIdentifier)",
                "MULTI_UI": "1",
            ]
            process.executableURL = createMacApp
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus
        }
        return try await task.value
    }
}
