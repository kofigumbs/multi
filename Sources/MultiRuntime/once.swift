fileprivate var run: Set<String> = []

func once(action: () -> Void, file: String = #file, line: Int = #line) {
    if run.update(with: "\(file):\(line)") == nil {
        action()
    }
}
