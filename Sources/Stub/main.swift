import Shared
import AppKit

guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "sexy.kofi.multi"),
      let bundle = Bundle(url: app) else {
    Program.error(code: 1, message: "Multi.app is missing — try installing it first.")
}

guard let runtime = bundle.url(forResource: "Runtime", withExtension: nil) else {
    Program.error(code: 2, message: "Multi.app is missing essential files — try re-installing it.")
}

do {
    try Process.execute(runtime, arguments: [ Bundle.main.bundlePath ].compactMap { $0 })
} catch {
    Program.error(code: 3, message: "Your Multi app quit unexpectedly — please report this error.")
}
