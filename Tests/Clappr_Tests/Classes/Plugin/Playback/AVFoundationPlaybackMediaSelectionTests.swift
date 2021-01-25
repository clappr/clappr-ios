import Quick
import Nimble
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackMediaSelectionTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackMediaSelection") {
            describe("subtitle selection") {
                var stubsDescriptor: OHHTTPStubsDescriptor?

                beforeEach {
                    OHHTTPStubs.removeAllStubs()

                    stubsDescriptor = stub(condition: isHost("clappr.io")   ) { result in
                        let stubPath = OHPathForFile("sample.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"application/vnd.apple.mpegURL; charset=utf-8"])
                    }

                    stubsDescriptor?.name = "StubToHighlineVideo.mp4"
                }

                afterEach {
                    OHTTPStubsHelper.removeStub(with: stubsDescriptor)
                }

                context("when option defaultSubtitle is off") {
                    it("sets language to off") {
                        let options = [
                            kSourceUrl: "http://clappr.io/highline.mp4",
                            kDefaultSubtitle: "off"
                        ]
                        let avfoundationPlayback = AVFoundationPlayback(options: options)
                        avfoundationPlayback.render()
                        
                        avfoundationPlayback.play()

                        expect(avfoundationPlayback.selectedSubtitle?.language).toEventually(equal("off"))
                    }
                }

                context("when option defaultSubtitle is pt") {
                    it("sets language to pt") {
                        let options = [
                            kSourceUrl: "http://clappr.io/highline.mp4",
                            kDefaultSubtitle: "pt"
                        ]
                        let avfoundationPlayback = AVFoundationPlayback(options: options)
                        avfoundationPlayback.view.bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
                        avfoundationPlayback.render()

                        avfoundationPlayback.play()

                        expect(avfoundationPlayback.selectedSubtitle?.language).toEventually(equal("pt"))
                    }
                }
            }
        }
    }
}
