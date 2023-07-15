import SwiftUI
import WebKit

public struct SettingsView: View {
    struct Error: Swift.Error {
        let message: String
    }

    private let newApp: Bool
    private let file = Bundle.multi?.url(forResource: "settings", withExtension: "html")

    public init(newApp: Bool) {
        self.newApp = newApp
    }

    var scripts: [WKUserScript] {
        if newApp {
            return [WKUserScript(
                source: """
                document.getElementById("json").value = `{
                  "tabs": [
                    {
                      "title": "Your first Multi app",
                      "url": "https://github.com/kofigumbs/multi#json-configuration"
                    }
                  ]
                }`
                """,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )]
        }
        else if let configFile = Bundle.main.url(forResource: "config", withExtension: "json"),
                let configContent = try? String(contentsOf: configFile),
                let name = try? JSONEncoder().encode(Bundle.main.title ?? ""),
                let json = try? JSONEncoder().encode(configContent) {
            return [WKUserScript(
                source: """
                    document.getElementById("name").value = \(String(data: name, encoding: .utf8)!)
                    document.getElementById("name").disabled = true
                    document.getElementById("json").value = \(String(data: json, encoding: .utf8)!)
                    document.getElementById("save").disabled = false
                """,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )]
        }
        else {
            return []
        }
    }

    public var body: some View {
        ContentView { webView in
            if let file = file {
                webView.loadFileURL(file, allowingReadAccessTo: file)
            }
            else {
                webView.load(URLRequest(url: URL(cannotOpen: "settings.html")))
            }
        }
            .with(
                scripts: scripts,
                handlers: ["icon": icon, "json": json, "save": save]
            )
    }

    func icon(_: NSObject) async throws -> Any {
        let task = Task { @MainActor in
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = true
            openPanel.allowedContentTypes = [.png, .icns]
            let result = await openPanel.beginSheetModal(for: NSApp.mainWindow!)
            return result == .OK ? openPanel.url?.path : nil
        }
        return await task.value ?? ""
    }

    func json(message: NSObject) async throws -> Any {
        guard let json = message as? String,
              let data = json.data(using: .utf8) else {
            throw Error(message: "JSON Configuration is not UTF8-encoded")
        }
        _ = try JSONDecoder().decode(Config.self, from: data)
        return 0
    }

    func save(message: NSObject) async throws -> Any {
        guard let name = message.value(forKey: "name") as? String,
              let json = message.value(forKey: "json") as? String,
              let createMacApp = Bundle.multi?.url(forResource: "create-mac-app", withExtension: nil) else {
            throw Error(message: "App Name and JSON Configuration are required to run create-mac-app")
        }
        let task = Task.detached(priority: .userInitiated) {
            let process = Process()
            let pipe = Pipe()
            process.environment = [
                "MULTI_APP_NAME": name,
                "MULTI_ICON_PATH": message.value(forKey: "icon") as? String ?? "",
                "MULTI_JSON_CONFIG": json,
                "MULTI_OVERWRITE": newApp ? "0" : "1",
                "MULTI_RELAUNCH_PID": "\(ProcessInfo.processInfo.processIdentifier)",
                "MULTI_UI": "1",
            ]
            process.executableURL = createMacApp
            process.standardError = pipe
            process.standardOutput = pipe
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                let message = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8)
                throw Error(message: message ?? "create-mac-app exited with code \(process.terminationStatus)")
            }
            return process.terminationStatus
        }
        return try await task.value
    }
}
