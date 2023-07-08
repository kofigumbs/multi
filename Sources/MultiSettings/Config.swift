import Foundation

public struct Config: Decodable {
    public struct Tab: Decodable {
        public var title: String
        public var url: URL
        public var customCss: [URL] = []
        public var customJs: [URL] = []
        public var basicAuthUser: String?
        public var basicAuthPassword: String?
        public var userAgent: String?
    }

    public var windowed = false
    public var keepOpenAfterWindowClosed = false
    public var alwaysNotify = false
    public var alwaysOnTop = false
    public var openNewWindowsWith: String?
    public var openNewWindowsInBackground = false
    public var tabs: [Tab]
}
