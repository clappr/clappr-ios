import AVFoundation

protocol MediaAssetWithCookies {
    var options: [String: Any]? { get }
    var cookies: [HTTPCookie]? { get }
    var asset: AVURLAsset? { get }

    init(url URL: URL, options: [String: Any]?)
}

class AVURLAssetWithCookies: MediaAssetWithCookies {
    private var url: URL

    internal(set) var options: [String: Any]?

    var cookies: [HTTPCookie]? {
        return self.options?[AVURLAssetHTTPCookiesKey] as? [HTTPCookie]
    }

    var asset: AVURLAsset? {
        return AVURLAsset.init(url: self.url, options: self.options)
    }

    required init(url URL: URL, options: [String: Any]? = nil) {
        self.url = URL
        self.options = self.optionsWithCookies(options)
    }

    private func optionsWithCookies(_ options: [String: Any]?) -> [String: Any] {
        if var options = options {
            options[AVURLAssetHTTPCookiesKey] = self.cookiesFor(self.url)
            return options
        } else {
            return [AVURLAssetHTTPCookiesKey: self.cookiesFor(self.url) as Any]
        }
    }

    private func cookiesFor(_ url: URL) -> [HTTPCookie]? {
        if let host = url.host, let cookieUrl = URL(string: "http://\(host)") {
            return HTTPCookieStorage.shared.cookies(for: cookieUrl)
        }
        return nil
    }
}
