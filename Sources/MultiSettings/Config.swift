import Foundation

public struct Config: Decodable {
    public struct Tab: Decodable {
        public var title: String
        public var url: URL
        public var userAgent: String?

        @DecodableDefault.EmptyString
        public var basicAuthUser: String
        @DecodableDefault.EmptyString
        public var basicAuthPassword: String
        @DecodableDefault.EmptyList
        public var customCss: [URL]
        @DecodableDefault.EmptyList
        public var customJs: [URL]
        @DecodableDefault.EmptyList
        public var customCookies: [Cookie]

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
    public var openNewWindowsWith: String?

    @DecodableDefault.False
    public var windowed: Bool
    @DecodableDefault.False
    public var keepOpenAfterWindowClosed: Bool
    @DecodableDefault.False
    public var alwaysNotify: Bool
    @DecodableDefault.False
    public var alwaysOnTop: Bool
    @DecodableDefault.False
    public var openNewWindowsInBackground: Bool

    public init(tabs: [Tab]) {
        self.tabs = tabs
    }
}
