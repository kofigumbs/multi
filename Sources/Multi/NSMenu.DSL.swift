import WebKit

extension NSMenu {
    struct DSL {
        let item: NSMenuItem

        static func sub(_ menu: NSMenu) -> DSL {
            let entry = DSL(item: NSMenuItem())
            entry.item.submenu = menu
            return entry
        }

        static func divider() -> DSL {
            return DSL(item: NSMenuItem.separator())
        }

        static func shortcut(_ keyEquivalent: String, _ title: String, _ action: Selector, target: AnyObject? = nil, modifiers: NSEvent.ModifierFlags? = nil) -> DSL {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
            target.map { item.target = $0 }
            modifiers.map { item.keyEquivalentModifierMask = $0 }
            return DSL(item: item)
        }
    }

    func items(_ items: [DSL]) -> NSMenu {
        items.forEach { addItem($0.item) }
        return self
    }
}
