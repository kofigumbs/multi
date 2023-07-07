import AppKit

extension NSTextField {
    @objc func undo(_: Any? = nil) {
        self.undoManager?.undo()
    }

    @objc func redo(_: Any? = nil) {
        self.undoManager?.redo()
    }
}
