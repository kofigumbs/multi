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

        public init(title: String, url: URL) {
            self.title = title
            self.url = url
        }
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

    public static let fallback = Config(tabs: [Config.Tab(
        title: "",
        url: URL(string: "data:text/html;charset=utf-8,%3C%21DOCTYPE%20html%3E%0D%0ACannot%20open%20%3Ccode%3Econfig.json%3C%2Fcode%3E")!
    )])
}
