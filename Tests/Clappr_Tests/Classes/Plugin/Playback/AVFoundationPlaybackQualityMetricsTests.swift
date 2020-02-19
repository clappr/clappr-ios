import Quick
import Nimble
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackQualityMetricsTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackQualityMetricsTests") {
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

            context("when receive AVPlayerItemNewAccessLogEntry with new bitrate value") {
                it("changes the bitrate") {
                    let options = [
                        kSourceUrl: "http://clappr.io/highline.mp4"
                    ]
                    let avfoundationPlayback = AVFoundationPlayback(options: options)
                    let player = PlayerMock(bitrate: 7.0)
                    avfoundationPlayback.player = player
                    avfoundationPlayback.addObservers()

                    NotificationCenter.default.post(
                        name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                        object: player.currentItem
                    )

                    expect(avfoundationPlayback.bitrate).toEventually(equal(7.0))
                }
            }

        }
    }
}
