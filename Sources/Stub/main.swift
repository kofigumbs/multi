import Shared
import AppKit

guard let app = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "llc.gumbs.multi"),
      let bundle = Bundle(url: app) else {
    Program.error(code: 1, message: "Multi.app is missing — try installing it first.")
}

guard let runtime = bundle.url(forResource: "Runtime", withExtension: nil) else {
    Program.error(code: 2, message: "Multi.app is missing essential files — try re-installing it.")
}

let process = Process()
process.arguments = [ Bundle.main.bundlePath ].compactMap { $0 }
process.execute(runtime)
process.waitUntilExit()
