import AppKit

Preferences.view()

NSApp.mainMenu = NSMenu()
NSApp.mainMenu!.addItem(NSMenuItem())
NSApp.mainMenu!.items.first!.submenu = NSMenu()
NSApp.mainMenu!.items.first!.submenu!.addItem(NSMenuItem(title: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
NSApp.mainMenu!.items.first!.submenu!.addItem(NSMenuItem(title: "Quit Multi", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

Program().start()
