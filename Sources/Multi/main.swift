import WebKit

Config.tabs.first?.view()

NSApp.mainMenu = NSMenu().items([
    .sub(NSMenu().items([
        .shortcut("h", "Hide \(Browser.title)", #selector(NSApplication.hide(_:))),
        .divider(),
        .shortcut("q", "Quit \(Browser.title)", #selector(NSApplication.terminate(_:))),
    ])),
    .sub(NSMenu(title: "Edit").items([
        .shortcut("x", "Cut", #selector(NSText.cut(_:))),
        .shortcut("c", "Copy", #selector(NSText.copy(_:))),
        .shortcut("v", "Paste", #selector(NSText.paste(_:))),
        .shortcut("a", "Select All", #selector(NSText.selectAll(_:))),
    ])),
    .sub(NSMenu(title: "View")),
    .sub(NSMenu(title: "Tab").items(
        Config.tabs.enumerated().map { (index, tab) in
            .shortcut("\(index + 1)", tab.title, #selector(Tab.view(_:)), target: tab)
        }
    )),
    .sub(NSMenu(title: "Window").items([
        .shortcut("w", "Hide", #selector(NSApplication.hide(_:))),
        .shortcut("m", "Minimze", #selector(NSApplication.miniaturizeAll(_:))),
    ])),
])

_ = NSApplication.shared
NSApp.delegate = Browser.global
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
