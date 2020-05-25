import WebKit

Config.browsers.first?.view()

NSApp.mainMenu = NSMenu().items([
    .sub(NSMenu().items([
        .shortcut("h", "Hide", #selector(NSApplication.hide(_:))),
        .shortcut("m", "Minimze", #selector(NSApplication.miniaturizeAll(_:))),
        .shortcut("q", "Quit", #selector(NSApplication.terminate(_:))),
    ])),
    .sub(NSMenu(title: "Edit").items([
        .shortcut("x", "Cut", #selector(NSText.cut(_:))),
        .shortcut("c", "Copy", #selector(NSText.copy(_:))),
        .shortcut("v", "Paste", #selector(NSText.paste(_:))),
        .shortcut("a", "Select All", #selector(NSText.selectAll(_:))),
    ])),
    .sub(NSMenu(title: "View").items(
        Config.browsers.enumerated().map { (index, browser) in
            NSMenu.Entry
                .shortcut("\(index + 1)", browser.title, #selector(Browser.view))
                .target(browser)
        }
    ))
])

_ = NSApplication.shared
NSApp.delegate = WindowManager.singleton
NSApp.setActivationPolicy(.regular)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
