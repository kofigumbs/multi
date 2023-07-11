class Once {
    var run = false

    func callAsFunction(action: () -> Void) {
        if !run {
            action()
            run = true
        }
    }
}
