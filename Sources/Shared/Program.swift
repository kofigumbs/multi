import AppKit

public class Program: NSObject, NSApplicationDelegate {
    static let title: String = {
        switch Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
        case .none:
            return "Multi"
        case .some(let version):
            return "Multi — \(version)"
        }
    }()

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    public func start(menu: NSMenu) {
        NSApp.mainMenu = menu
        _ = NSApplication.shared
        NSApp.delegate = self
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.run()
    }

    public func error(code: Int32, message: String) -> Never {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 80),
            styleMask: [.titled, .closable],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false
        )
        window.title = Program.title
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        window.center()

        let text = NSTextView(frame: window.contentView!.bounds)
        text.string = message
        text.backgroundColor = .clear
        text.isEditable = false
        text.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        text.textContainerInset = NSSize(width: 20, height: 20)
        window.contentView = text

        start(menu: .default)
        exit(code)
    }
}
