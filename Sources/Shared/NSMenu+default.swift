import AppKit

extension NSMenu {
    public static let `default`: NSMenu = {
        let menu = NSMenu()
        menu.addItem(NSMenuItem())
        menu.items.first!.submenu = NSMenu()
        menu.items.first!.submenu!.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        menu.items.first!.submenu!.addItem(NSMenuItem(title: "Quit Multi", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }()
}
