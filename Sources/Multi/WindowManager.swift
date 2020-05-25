import WebKit

class WindowManager: NSObject, NSApplicationDelegate {
    static let singleton = WindowManager()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
