import AppKit

public class Program: NSObject {
    static let title: String = {
        // TODO don't rely on Bundle.main (this can be run from preferences)
        switch Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
        case .none:
            return "Multi"
        case .some(let version):
            return "Multi — \(version)"
        }
    }()

    private static let mainMenu: NSMenu = {
        let menu = NSMenu()
        NSApp.mainMenu = menu
        return menu
    }()

    private static func addSubmenu(_ menu: NSMenu, _ submenu: [NSMenuItem]) {
        let item = NSMenuItem()
        item.submenu = menu
        submenu.forEach(menu.addItem)
        mainMenu.addItem(item)
    }

    public init(name: String) {
        Program.addSubmenu(NSMenu(), [
            NSMenuItem(title: "Hide \(name)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "h"),
            NSMenuItem(title: "Quit \(name)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"),
        ])
        Program.addSubmenu(NSMenu(title: "Edit"), [
            NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
            NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
            NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"),
            NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"),
        ])
    }

    public func preferences(target: AnyObject, action: Selector) -> Program {
        let item = NSMenuItem(title: "Preferences", action: action, keyEquivalent: ",")
        item.target = target
        Program.mainMenu.items.first!.submenu!.items.insert(item, at: 0)
        Program.mainMenu.items.first!.submenu!.items.insert(.separator(), at: 1)
        return self
    }

    public func start(menu: KeyValuePairs<String, [NSMenuItem]>) {
        for (name, submenu) in menu {
            Program.addSubmenu(NSMenu(title: name), submenu)
        }

        if #available(macOS 10.12, *) {
            NSWindow.allowsAutomaticWindowTabbing = false
        }

        _ = NSApplication.shared
        NSApp.delegate = self
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.run()
    }

    public static func error(code: Int32, message: String) -> Never {
        let window = self.window(
            title: title,
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 80),
            styleMask: [.titled, .closable]
        )

        let text = NSTextView(frame: window.contentView!.bounds)
        text.string = message
        text.backgroundColor = .clear
        text.isEditable = false
        text.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        text.textContainerInset = NSSize(width: 20, height: 20)
        window.contentView = text

        Program(name: "Multi").start(menu: [:])
        exit(code)
    }

    public static func window(title: String, contentRect: NSRect, styleMask: NSWindow.StyleMask) -> NSWindow {
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        window.center()
        return window
    }
}
