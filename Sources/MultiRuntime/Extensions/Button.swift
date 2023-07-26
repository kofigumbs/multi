import SwiftUI

extension Button where Label == Text {
    init(_ text: String, _ selector: Selector) {
        self.init(text) {
            NSApp.sendAction(selector, to: nil, from: nil)
        }
    }
}
