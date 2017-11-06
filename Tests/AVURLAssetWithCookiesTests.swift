import Quick
import Nimble
import AVFoundation

@testable import Clappr

class AVURLAssetWithCookiesTests: QuickSpec {
    override func spec() {
        describe("a AVURLAsset with cookies") {

            var cookie: HTTPCookie!

            beforeEach {
                cookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: "clappr.io",
                                                 HTTPCookiePropertyKey.path: "/",
                                                 HTTPCookiePropertyKey.name: "testing",
                                                 HTTPCookiePropertyKey.value: "it was sent"])!
                HTTPCookieStorage.shared.setCookie(cookie)
            }

            afterEach {
                HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            }

            it("sets the cookies associated with the media url") {
                let avUrlAssetWithCookies = AVURLAssetWithCookies(url: URL(string: "http://clappr.io/highline.mp4")!)

                expect(avUrlAssetWithCookies.cookies?.count).to(equal(1))
                expect(avUrlAssetWithCookies.cookies?.first).to(equal(cookie))
            }

            it("doesn't sets cookies that aren't associated with the media url") {
                let anotherCookie = HTTPCookie(properties: [HTTPCookiePropertyKey.domain: "anotherdomain.io",
                                                 HTTPCookiePropertyKey.path: "/",
                                                 HTTPCookiePropertyKey.name: "testing",
                                                 HTTPCookiePropertyKey.value: "don't send me"])!
                HTTPCookieStorage.shared.setCookie(anotherCookie)

                let avUrlAssetWithCookies = AVURLAssetWithCookies(url: URL(string: "http://clappr.io/highline.mp4")!)

                expect(avUrlAssetWithCookies.cookies?.count).to(equal(1))
                expect(avUrlAssetWithCookies.cookies).toNot(contain(anotherCookie))
            }

            it("sets the cookies and maintains the existing options") {
                let avUrlAssetWithCookies = AVURLAssetWithCookies(
                    url: URL(string: "http://clappr.io/highline.mp4")!,
                    options: ["foo":"bar"]
                )

                expect(avUrlAssetWithCookies.cookies?.count).to(equal(1))
                expect((avUrlAssetWithCookies.options?["foo"] as! String)).to(equal("bar"))
            }

            it("has a AVURLAsset") {
                let avUrlAssetWithCookies = AVURLAssetWithCookies(url: URL(string: "http://clappr.io/highline.mp4")!)

                expect(avUrlAssetWithCookies.asset).toNot(beNil())
                expect(avUrlAssetWithCookies.asset).to(beAKindOf(AVURLAsset.self))
            }
        }
    }
}

