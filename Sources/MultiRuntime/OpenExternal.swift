import AppKit
import MultiSettings

struct OpenExternal {
    let config: Config

    func callAsFunction(url: URL) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = !config.openNewWindowsInBackground
        if let application = config.openNewWindowsWith,
           let applicationURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: application) {
            NSWorkspace.shared.open([url], withApplicationAt: applicationURL, configuration: configuration)
        } else {
            NSWorkspace.shared.open(url, configuration: configuration)
        }
    }
}
