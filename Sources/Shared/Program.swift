import AppKit

public class Program: NSObject {
    public static let messageFrame = NSRect(x: 0, y: 0, width: 500, height: 80)

    static let title: String = {
        switch Bundle.multi?.version {
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

    public init(name: String, menu: [NSMenuItem] = []) {
        Program.addSubmenu(NSMenu(), menu + [
            NSMenuItem(title: "Hide \(name)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
            NSMenuItem(title: "Quit \(name)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"),
        ])
        Program.addSubmenu(NSMenu(title: "Edit"), [
            NSMenuItem(title: "Undo", action: #selector(NSTextField.undo(_:)), keyEquivalent: "z"),
            NSMenuItem(title: "Redo", action: #selector(NSTextField.redo(_:)), keyEquivalent: "z", modifiers: [.command, .shift]),
            .separator(),
            NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
            NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
            NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"),
            NSMenuItem(title: "Paste and Match Style", action: #selector(NSTextView.pasteAsPlainText(_:)), keyEquivalent: "v", modifiers: [.command, .shift]),
            NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"),
        ])
    }

    public func start(menu: KeyValuePairs<String, [NSMenuItem]>) {
        for (name, submenu) in menu {
            Program.addSubmenu(NSMenu(title: name), submenu)
        }

        _ = NSApplication.shared
        NSApp.delegate = self
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.run()
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
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        return window
    }

    static func error(message: String) -> NSTextView {
        let window = self.window(title: title, contentRect: messageFrame, styleMask: [.titled, .closable])

        let text = NSTextView(frame: window.contentView!.bounds)
        text.string = message
        text.backgroundColor = .clear
        text.isEditable = false
        text.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        text.textContainerInset = NSSize(width: 20, height: 20)
        window.contentView = text
        return text
    }
}
