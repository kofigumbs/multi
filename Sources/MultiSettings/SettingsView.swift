import SwiftUI
import WebKit

public struct SettingsView: View {
    struct MissingHandlerDependencies: Error {}

    let overwrite: Bool

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
        // TODO inject initialize script or add `init` delegete message
        return html
    }

    public var body: some View {
        ContentView(handlers: [
            "checkJson": checkJson,
            "save": save,
        ]) { webView in
            webView.loadHTMLString(html, baseURL: nil)
        }
    }

    func checkJson(message: NSObject) async throws -> Any {
        guard let json = message.value(forKey: "json") as? String,
              let data = json.data(using: .utf8) else {
            throw MissingHandlerDependencies()
        }
        _ = try JSONDecoder().decode(Config.self, from: data)
        return 0
    }

    func save(message: NSObject) async throws -> Any {
        guard let name = message.value(forKey: "name") as? String,
              let icon = message.value(forKey: "icon") as? String,
              let json = message.value(forKey: "json") as? String,
              let createMacApp = Bundle.multi?.url(forResource: "create-mac-app", withExtension: nil) else {
            throw MissingHandlerDependencies()
        }
        let task = Task.detached(priority: .userInitiated) {
            let process = Process()
            process.environment = [
                "MULTI_APP_NAME": name,
                "MULTI_ICON_PATH": icon,
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
