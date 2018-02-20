import AVFoundation

protocol AVURLAssetWithCookies {
    var options: [String: Any] { get }
    var cookies: [HTTPCookie]? { get }
    var asset: AVURLAsset? { get }

    init(url URL: URL, options: [String: Any])
}

struct AVURLAssetWithCookiesBuilder: AVURLAssetWithCookies {
    private var url: URL

    internal(set) var options: [String: Any]

    var cookies: [HTTPCookie]? {
        didSet {
            self.options[AVURLAssetHTTPCookiesKey] = cookies
        }
    }

    var asset: AVURLAsset? {
        return AVURLAsset(url: url, options: options)
    }

    init(url URL: URL, options: [String: Any] = [:]) {
        self.url = URL
        self.options = options
        setCookies()
    }

    private mutating func setCookies() {
        cookies = getCookies()
    }

    private func getCookies() -> [HTTPCookie]? {
        let url = self.url.absoluteString
        return HTTPCookieStorage.shared.cookies?.filter { url.range(of:$0.domain) != nil }
    }
}
