import WebKit

/*
 * DSL for nicer menu creation
 */
extension NSMenu {
    struct Entry {
        let item: NSMenuItem

        static func sub(_ menu: NSMenu) -> Entry {
            let entry = Entry(item: NSMenuItem())
            entry.item.submenu = menu
            return entry
        }

        static func shortcut(_ keyEquivalent: String, _ title: String, _ action: Selector, target: AnyObject? = nil, hidden: Bool? = nil) -> Entry {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
            target.map { item.target = $0 }
            hidden.map { item.isHidden = $0 }
            if #available(macOS 10.13, *) {
                item.allowsKeyEquivalentWhenHidden = true
            }
            return Entry(item: item)
        }
    }

    func items(_ items: [Entry]) -> NSMenu {
        items.forEach { addItem($0.item) }
        return self
    }
}
