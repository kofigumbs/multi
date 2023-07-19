import SwiftUI
import WebKit
import MultiSettings

struct Runtime: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var delegate

    @Environment(\.openWindow)
    var openWindow

    var body: some Scene {
        WindowGroup(for: Int.self) { $index in
            TabView(tab: delegate.config.tabs[index], index: index, appDelegate: delegate) { window in
                once {
                    for i in delegate.config.tabs.indices {
                        openWindow(value: i)
                    }
                    delegate.openWindow = openWindow
                    window.makeKeyAndOrderFront(nil)
                }
                if delegate.config.alwaysOnTop {
                    window.level = .floating
                }
                if !delegate.config.windowed {
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
                    ForEach(0 ..< min(delegate.config.tabs.count, 9), id: \.self) { index in
                        Button(delegate.config.tabs[index].title) {
                            openWindow(value: index)
                        }
                            .keyboardShortcut(KeyEquivalent((index+1).description.first!))
                    }
                }
                CommandGroup(after: .sidebar) {
                    button("Reload Page", #selector(WKWebView.reload(_:)))
                        .keyboardShortcut("R")
                    button("Actual Size", #selector(WKWebView.actualSize(_:)))
                        .keyboardShortcut("0")
                    button("Zoom In", #selector(WKWebView.zoomIn(_:)))
                        .keyboardShortcut("+")
                    button("Zoom Out", #selector(WKWebView.zoomOut(_:)))
                        .keyboardShortcut("-")
                }
                CommandMenu("History") {
                    button("Back", #selector(WKWebView.goBack(_:)))
                        .keyboardShortcut("[")
                    button("Forward", #selector(WKWebView.goForward(_:)))
                        .keyboardShortcut("]")
                }
            }
        Settings {
            SettingsView()
        }
    }

    func button(_ text: String, _ selector: Selector) -> Button<Text> {
        Button(text) {
            NSApp.sendAction(selector, to: nil, from: nil)
        }
    }
}

@_cdecl("RuntimeMain")
public func RuntimeMain() {
    Runtime.main()
}
