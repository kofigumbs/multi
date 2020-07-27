import Foundation

extension Process {
    public func execute(_ url: URL) {
        if #available(macOS 10.13, *) {
            executableURL = url
            try! run()
        } else {
            launchPath = url.path
            launch()
        }
    }
}
