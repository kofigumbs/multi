import Foundation

extension Bundle {
    static let stub = CommandLine.arguments.last
        .flatMap { URL(fileURLWithPath: $0) }
        .flatMap { Bundle(url: $0) }
}
