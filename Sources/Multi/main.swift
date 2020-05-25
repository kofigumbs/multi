import WebKit

Config.browsers.first?.view()

NSApp.mainMenu = NSMenu().items([
    .sub(NSMenu().items([
        .shortcut("h", "Hide", #selector(NSApplication.hide)),
        .shortcut("m", "Minimze", #selector(NSApplication.miniaturizeAll)),
        .shortcut("q", "Quit", #selector(NSApplication.terminate)),
    ])),
    .sub(NSMenu(title: "Edit").items([
        .shortcut("x", "Cut", #selector(NSText.cut)),
        .shortcut("c", "Copy", #selector(NSText.copy)),
        .shortcut("v", "Paste", #selector(NSText.paste)),
        .shortcut("a", "Select All", #selector(NSText.selectAll)),
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
