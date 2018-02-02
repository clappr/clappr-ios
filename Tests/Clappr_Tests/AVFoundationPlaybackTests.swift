import Quick
import Nimble
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackTests: QuickSpec {

    override func spec() {
        describe("AVFoundationPlayback Tests") {

            context("canPlay") {
                it("Should return true for valid url with mp4 path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.mp4"]
                    let canPlay = AVFoundationPlayback.canPlay(options as Options)
                    expect(canPlay) == true
                }

                it("Should return true for valid url with m3u8 path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.m3u8"]
                    let canPlay = AVFoundationPlayback.canPlay(options as Options)
                    expect(canPlay) == true
                }

                it("Should return true for valid url without path extension with supported mimetype") {
                    let options = [kSourceUrl: "http://clappr.io/highline", kMimeType: "video/avi"]
                    let canPlay = AVFoundationPlayback.canPlay(options as Options)
                    expect(canPlay) == true
                }

                it("Should return false for invalid url") {
                    let options = [kSourceUrl: "123123"]
                    let canPlay = AVFoundationPlayback.canPlay(options as Options)
                    expect(canPlay) == false
                }

                it("Should return false for url with invalid path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.zip"]
                    let canPlay = AVFoundationPlayback.canPlay(options as Options)
                    expect(canPlay) == false
                }
            }

            describe("#seek") {

                var avFoundationPlayback: AVFoundationPlayback!

                beforeEach {
                    stub(condition: isHost("clappr.io")) { _ in
                        let stubPath = OHPathForFile("video.mp4", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"video/mp4"])
                    }
                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "https://clappr.io/highline.mp4"])

                    avFoundationPlayback.play()
                }

                it("triggers seek event") {
                    waitUntil { done in
                        let listener = BaseObject()

                        listener.listenTo(avFoundationPlayback, eventName: Event.seek.rawValue) { info in
                            done()
                        }

                        avFoundationPlayback.seek(5)
                    }
                }

                it("triggers didSeek when a seek is completed") {
                    waitUntil { done in
                        let listener = BaseObject()

                        listener.listenTo(avFoundationPlayback, eventName: Event.didSeek.rawValue) { info in
                            expect(info!["success"] as? Bool).to(beTrue())
                            done()
                        }

                        avFoundationPlayback.seek(5)
                    }
                }

                it("triggers positionUpdate for the desired position") {
                    waitUntil { done in
                        let listener = BaseObject()

                        listener.listenTo(avFoundationPlayback, eventName: Event.positionUpdate.rawValue) { info in
                            expect(info!["position"] as? Float64).to(equal(5))
                            done()
                        }

                        avFoundationPlayback.seek(5)
                    }
                }
            }
        }
    }
}
