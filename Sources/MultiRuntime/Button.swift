import AppKit
import SwiftUI

extension Button where Label == Text {
    init(_ title: String, _ selector: Selector) {
        self.init(title) {
            NSApp.sendAction(selector, to: nil, from: nil)
        }
    }
}
