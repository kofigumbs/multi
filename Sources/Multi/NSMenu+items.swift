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

        static func shortcut(_ keyEquivalent: String, _ title: String, _ action: Selector) -> Entry {
            return Entry(
                item: NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
            )
        }

        func target(_ this: AnyObject) -> Entry {
            self.item.target = this
            return self
        }
    }

    func items(_ items: [Entry]) -> NSMenu {
        items.forEach { addItem($0.item) }
        return self
    }
}
