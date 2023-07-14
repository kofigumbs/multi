import Foundation

public struct Config: Decodable {
    public struct Tab: Decodable {
        public var title: String
        public var url: URL
        public var basicAuthUser: String?
        public var basicAuthPassword: String?
        public var userAgent: String?
        @DecodableDefault.EmptyList
        public var customCss: [URL] = []
        @DecodableDefault.EmptyList
        public var customJs: [URL] = []
        @DecodableDefault.EmptyList
        public var customCookies: [Cookie] = []

        public init(title: String, url: URL) {
            self.title = title
            self.url = url
        }
    }

    public struct Cookie: Decodable {
        public var comment: String?
        public var commentURL: String?
        public var discard: String?
        public var domain: String?
        public var expires: String?
        public var maximumAge: String?
        public var name: String
        public var originURL: String?
        public var path: String
        public var port: String?
        public var secure: String?
        public var value: String
        public var version: String?
    }

    public var tabs: [Tab]
    @DecodableDefault.False
    public var windowed = false
    @DecodableDefault.False
    public var keepOpenAfterWindowClosed = false
    @DecodableDefault.False
    public var alwaysNotify = false
    @DecodableDefault.False
    public var alwaysOnTop = false
    @DecodableDefault.False
    public var openNewWindowsInBackground = false
    public var openNewWindowsWith: String?

    public init(tabs: [Tab]) {
        self.tabs = tabs
    }
}
