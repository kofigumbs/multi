import AppKit

extension Browser: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_: NSUserNotificationCenter, shouldPresent: NSUserNotification) -> Bool {
        return Config.alwaysNotify
    }
}
