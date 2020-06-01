import AppKit

guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "sexy.kofi.multi"),
      let bundle = Bundle(url: app) else {
    Error.window(message: "Multi.app is not installed — try installing it first.")
    exit(1)
}

guard let runner = bundle.url(forResource: "Runner", withExtension: nil) else {
    Error.window(message: "Multi.app is misconfigured or broken — try re-installing it.")
    exit(2)
}

guard let config = Bundle.main.path(forResource: "config", ofType: "json") else {
    Error.window(message: "Your config.json is missing — did you move it?")
    exit(3)
}

let process = Process()
process.arguments = [ config ]
try process.execute(runner)
process.waitUntilExit()
