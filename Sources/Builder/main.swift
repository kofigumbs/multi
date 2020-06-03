import WebKit

class Context: NSObject, NSApplicationDelegate, WKScriptMessageHandler {
    static let singleton = Context()
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    public func userContentController(_: WKUserContentController, didReceive: WKScriptMessage) {
        guard let argument = didReceive.body as? NSObject else { return }
        switch argument.value(forKey: "type") as? String {
        case "get-icon":
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = true
            openPanel.allowedFileTypes = ["png"]
            openPanel.begin { (result) in
                if let url = openPanel.url,
                       result == NSApplication.ModalResponse.OK {
                    // TODO
                }
            }
        default:
            return
        }
    }
}

let window = NSWindow(
    contentRect: NSScreen.main!.frame.applying(.init(scaleX: 0.5, y: 0.5)),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: NSWindow.BackingStoreType.buffered,
    defer: false
)

let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
window.title = "Multi" + (version == nil ? "" : " — \(version!)")
window.titlebarAppearsTransparent = true
window.makeKeyAndOrderFront(nil)
window.center()

let path = Bundle.main.path(forResource: "builder", ofType: "html")!
let html = try! String(contentsOf: URL(fileURLWithPath: path))
let webView = WKWebView(frame: window.frame)
webView.setValue(false, forKey: "drawsBackground")
webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
webView.configuration.userContentController.add(Context.singleton, name: "multi")
webView.loadHTMLString(html, baseURL: nil)
window.contentView = webView

NSApp.mainMenu = NSMenu()
NSApp.mainMenu!.addItem(NSMenuItem())
NSApp.mainMenu!.items.first!.submenu = NSMenu()
NSApp.mainMenu!.items.first!.submenu!.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
NSApp.mainMenu!.items.first!.submenu!.addItem(NSMenuItem(title: "Quit Multi", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

_ = NSApplication.shared
NSApp.delegate = Context.singleton
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
