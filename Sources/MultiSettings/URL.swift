import Foundation

extension URL {
    public init(cannotOpen filename: String) {
        self.init(string: "data:text/html;charset=utf-8,%3C%21DOCTYPE%20html%3E%0D%0ACannot%20open%20%3Ccode%3E\(filename)%3C%2Fcode%3E")!
    }
}
