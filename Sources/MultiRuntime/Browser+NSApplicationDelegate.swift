import AppKit

extension Browser: NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSUserNotificationCenter.default.delegate = self
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return !Config.keepOpenAfterWindowClosed
    }
}
