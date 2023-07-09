import SwiftUI
import WebKit
import MultiSettings

import os

@main
struct Runtime: App {
    @Environment(\.openWindow)
    var openWindow

    @State
    var once: [Void] = [()]

    let config: Config = {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(Config.self, from: data),
              !config.tabs.isEmpty else {
            return Config.fallback
        }
        return config
    }()

    var body: some Scene {
        WindowGroup(for: Int.self) { $index in
            TabView(tab: config.tabs[index]) { window in
                if let _ = once.popLast() {
                    for i in config.tabs.indices.reversed() {
                        openWindow(value: i)
                    }
                    if !config.windowed {
                        window.mergeAllWindows(nil)
                    }
                }
                if config.alwaysOnTop {
                    window.level = .floating
                }
                window.isExcludedFromWindowsMenu = true
            }
        } defaultValue: {
            config.tabs.count - 1
        }
            .commands {
                CommandGroup(replacing: .newItem) {}
                CommandGroup(after: .singleWindowList) {
                    ForEach(0 ..< min(config.tabs.count, 9), id: \.self) { index in
                        Button(config.tabs[index].title) {
                            openWindow(value: index)
                        }
                            .keyboardShortcut(KeyEquivalent((index+1).description.first!))
                    }
                }
            }
        Settings {
            SettingsView(newApp: false)
        }
    }
}
