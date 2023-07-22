import SwiftUI
import WebKit
import MultiSettings

struct Runtime: App {
    @NSApplicationDelegateAdaptor(RuntimeDelegate.self)
    var delegate

    @Environment(\.openWindow)
    var openWindow

    var body: some Scene {
        WindowGroup(for: Int.self) { $index in
            if delegate.config.tabs.isEmpty {
                let _ = DispatchQueue.main.async {
                    let window = NSApp.keyWindow
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    window?.close()
                }
            }
            else {
                TabView(index: index, delegate: .init(delegate.config.tabs[index], delegate)) { window in
                    once {
                        for i in delegate.config.tabs.indices.reversed() {
                            openWindow(value: i)
                        }
                        delegate.openWindow = openWindow
                        window.makeKeyAndOrderFront(nil)
                    }
                    if delegate.config.alwaysOnTop {
                        window.level = .floating
                    }
                    if !delegate.config.windowed {
                        NSApp.keyWindow?.tabGroup?.insertWindow(window, at: 1)
                    }
                    window.isExcludedFromWindowsMenu = true
                }
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
