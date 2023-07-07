import MultiSettings
import WebKit

let preferences = Preferences.update

if Config.tabs.isEmpty {
    preferences.view()
} else if Config.windowed {
    Config.tabs.first!.view()
} else {
    Config.tabs.dropLast().forEach { Config.tabs.last!.window.addTabbedWindow($0.window, ordered: .below) }
    Config.tabs.first!.view()
}

Program(name: Bundle.main.title ?? "Multi", menu: preferences.menuItems).start(delegate: Browser.global, menu: [
    "View": [
        .init(title: "Reload This Page", action: #selector(WKWebView.reload(_:)), keyEquivalent: "r"),
        .separator(),
        .init(title: "Toggle Tab Bar", action: #selector(NSWindow.toggleTabBar(_:)), keyEquivalent: "t", modifiers: [.command, .shift]),
        .init(title: "Toggle Tab Overview", action: #selector(NSWindow.toggleTabOverview(_:)), keyEquivalent: "\\", modifiers: [.command, .shift]),
        .separator(),
        .init(title: "Actual Size", action: #selector(WKWebView.actualSize(_:)), keyEquivalent: "0"),
        .init(title: "Zoom In", action: #selector(WKWebView.zoomIn(_:)), keyEquivalent: "+"),
        .init(title: "Zoom Out", action: #selector(WKWebView.zoomOut(_:)), keyEquivalent: "-"),
        .separator(),
        .init(title: "Toggle Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f", modifiers: [.command, .control]),
    ],
    "History": [
        .init(title: "Back", action: #selector(WKWebView.goBack(_:)), keyEquivalent: "["),
        .init(title: "Forward", action: #selector(WKWebView.goForward(_:)), keyEquivalent: "]"),
    ],
    "Tab": [
        .init(title: "Select Next Tab", action: #selector(NSWindow.selectNextTab(_:)), keyEquivalent: "⇥", modifiers: [.control]),
        .init(title: "Select Previous Tab", action: #selector(NSWindow.selectPreviousTab(_:)), keyEquivalent: "⇥", modifiers: [.control, .shift]),
        .init(title: "Copy URL", action: #selector(WKWebView.copyUrl(_:)), keyEquivalent: "l"),
        .separator(),
    ] + Config.tabs.enumerated().map { (index, tab) in
        .init(title: tab.title, action: #selector(Tab.view(_:)), keyEquivalent: index >= 9 ? "" : "\(index + 1)", target: tab)
    },
    "Window": [
        .init(title: "Close Tab", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"),
        .init(title: "Minimize", action: #selector(NSApplication.miniaturizeAll(_:)), keyEquivalent: "m"),
    ],
])
