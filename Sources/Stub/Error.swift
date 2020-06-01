import AppKit

class Error: NSObject, NSApplicationDelegate {
    private static let singleton = Error()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    static func window(message: String) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 80),
            styleMask: [.titled, .closable],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false
        )
        window.cascadeTopLeft(from: .zero)
        window.title = "Multi"
        window.makeKeyAndOrderFront(nil)
        window.center()

        let text = NSTextView(frame: window.contentView!.bounds)
        text.string = message
        text.backgroundColor = .clear
        text.isEditable = false
        text.setFont(NSFont.boldSystemFont(ofSize: 0), range: NSRange(location: 0, length: message.count))
        text.textContainerInset = NSSize(width: 20, height: 20)
        window.contentView = text

        NSApp.mainMenu = NSMenu()
        NSApp.mainMenu!.addItem(NSMenuItem())
        NSApp.mainMenu!.items.first!.submenu = NSMenu()
        NSApp.mainMenu!.items.first!.submenu!.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
        NSApp.mainMenu!.items.first!.submenu!.addItem(NSMenuItem(title: "Quit Multi", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        _ = NSApplication.shared
        NSApp.delegate = singleton
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.run()
    }
}
