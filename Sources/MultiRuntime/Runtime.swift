import SwiftUI
import WebKit
import MultiSettings

struct Runtime: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var app

    @Environment(\.openWindow)
    var openWindow

    let once = Once()

    var body: some Scene {
        WindowGroup(for: Int.self) { $index in
            TabView(tab: app.config.tabs[index], index: index, app: app) { window in
                once {
                    for i in app.config.tabs.indices {
                        openWindow(value: i)
                    }
                    app.openWindow = openWindow
                    window.makeKeyAndOrderFront(nil)
                }
                if app.config.alwaysOnTop {
                    window.level = .floating
                }
                if !app.config.windowed {
                    NSApp.keyWindow?.tabGroup?.addWindow(window)
                }
                window.isExcludedFromWindowsMenu = true
            }
        } defaultValue: {
            0
        }
            .commands {
                CommandGroup(replacing: .newItem) {}
                CommandGroup(after: .singleWindowList) {
                    ForEach(0 ..< min(app.config.tabs.count, 9), id: \.self) { index in
                        Button(app.config.tabs[index].title) {
                            openWindow(value: index)
                        }
                            .keyboardShortcut(KeyEquivalent((index+1).description.first!))
                    }
                }
                CommandGroup(after: .sidebar) {
                    Button("Reload Page", #selector(WKWebView.reload(_:)))
                        .keyboardShortcut("R")
                    Button("Actual Size", #selector(WKWebView.actualSize(_:)))
                        .keyboardShortcut("0")
                    Button("Zoom In", #selector(WKWebView.zoomIn(_:)))
                        .keyboardShortcut("+")
                    Button("Zoom Out", #selector(WKWebView.zoomOut(_:)))
                        .keyboardShortcut("-")
                }
                CommandMenu("History") {
                    Button("Back", #selector(WKWebView.goBack(_:)))
                        .keyboardShortcut("[")
                    Button("Forward", #selector(WKWebView.goForward(_:)))
                        .keyboardShortcut("]")
                }
            }
        Settings {
            SettingsView(newApp: false)
        }
    }
}

@_cdecl("RuntimeMain")
public func RuntimeMain() {
    Runtime.main()
}
