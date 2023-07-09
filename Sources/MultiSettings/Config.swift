import Foundation

public struct Config: Decodable {
    public struct Tab: Decodable {
        public var title: String
        public var url: URL
        public var basicAuthUser: String?
        public var basicAuthPassword: String?
        public var userAgent: String?
        @DecodableDefault.EmptyList
        public var customCss: [URL]
        @DecodableDefault.EmptyList
        public var customJs: [URL]
    }

    public var tabs: [Tab]
    @DecodableDefault.False
    public var windowed
    @DecodableDefault.False
    public var keepOpenAfterWindowClosed
    @DecodableDefault.False
    public var alwaysNotify
    @DecodableDefault.False
    public var alwaysOnTop
    @DecodableDefault.False
    public var openNewWindowsInBackground
    public var openNewWindowsWith: String?
}
