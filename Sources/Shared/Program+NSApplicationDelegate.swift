import AppKit

extension Program: NSApplicationDelegate {
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
