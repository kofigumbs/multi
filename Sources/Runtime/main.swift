import Shared
import WebKit

let preferences = Preferences.update
Config.tabs.isEmpty ? preferences.view() : Config.tabs.first!.view()
Program(name: Browser.title, menu: preferences.menuItems).start(menu: [
    "View": [
        .init(title: "Reload This Page", action: #selector(WKWebView.reload(_:)), keyEquivalent: "r"),
        .separator(),
        .init(title: "Actual Size", action: #selector(WKWebView.actualSize(_:)), keyEquivalent: "0"),
        .init(title: "Zoom In", action: #selector(WKWebView.zoomIn(_:)), keyEquivalent: "+"),
        .init(title: "Zoom Out", action: #selector(WKWebView.zoomOut(_:)), keyEquivalent: "-"),
    ],
    "History": [
        .init(title: "Back", action: #selector(WKWebView.goBack(_:)), keyEquivalent: "["),
        .init(title: "Forward", action: #selector(WKWebView.goForward(_:)), keyEquivalent: "]"),
    ],
    "Tab": [
        .init(title: "Select Next Tab", action: #selector(Browser.nextTab(_:)), keyEquivalent: "⇥", target: Browser.global, modifiers: [.control]),
        .init(title: "Select Previous Tab", action: #selector(Browser.previousTab(_:)), keyEquivalent: "⇥", target: Browser.global, modifiers: [.control, .shift]),
        .init(title: "Copy URL", action: #selector(WKWebView.copyUrl(_:)), keyEquivalent: "l"),
        .separator(),
    ] + Config.tabs.enumerated().map { (index, tab) in
        .init(title: tab.title, action: #selector(Tab.view(_:)), keyEquivalent: index >= 9 ? "" : "\(index + 1)", target: tab)
    },
    "Window": [
        .init(title: "Hide", action: #selector(NSApplication.hide(_:)), keyEquivalent: "w"),
        .init(title: "Minimize", action: #selector(NSApplication.miniaturizeAll(_:)), keyEquivalent: "m"),
    ],
])
