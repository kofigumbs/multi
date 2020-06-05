import AppKit

extension NSMenuItem {
    convenience init(title: String, action: Selector, keyEquivalent: String, target: AnyObject, modifiers: NSEvent.ModifierFlags = .command) {
        self.init(title: title, action: action, keyEquivalent: keyEquivalent)
        self.target = target
        self.keyEquivalentModifierMask = modifiers
    }
}
