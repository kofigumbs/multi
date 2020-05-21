import WebKit

let browsers = Browser.configure()
browsers.first?.view()

NSApp.mainMenu = NSMenu().items([
    .sub(NSMenu().items([ .shortcut("q", "Quit", #selector(NSApplication.terminate)) ])),
    .sub(NSMenu(title: "Edit").items([
        .shortcut("x", "Cut", #selector(NSText.cut)),
        .shortcut("c", "Copy", #selector(NSText.copy)),
        .shortcut("v", "Paste", #selector(NSText.paste)),
        .shortcut("a", "Select All", #selector(NSText.selectAll)),
    ])),
    .sub(NSMenu(title: "View").items(
        browsers.enumerated().map { (index, browser) in
            NSMenu.Entry
                .shortcut("\(index + 1)", browser.title, #selector(Browser.view))
                .target(browser)
        }
    ))
])

let _ = NSApplication.shared
NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
NSApp.activate(ignoringOtherApps: true)
NSApp.run()
