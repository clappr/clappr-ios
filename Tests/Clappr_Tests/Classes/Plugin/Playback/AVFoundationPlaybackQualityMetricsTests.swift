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

            context("when receives AVPlayerItemNewAccessLogEntry event") {
                context("with new indicatedBitrate value") {
                    it("changes the bitrate") {
                        let options = [
                            kSourceUrl: "http://clappr.io/highline.mp4"
                        ]
                        let avfoundationPlayback = AVFoundationPlayback(options: options)
                        let accessLog = AccessLogEventMock()
                        accessLog.setIndicatedBitrate(7.0)
                        let player = PlayerMock(accessLogEvent: accessLog)
                        avfoundationPlayback.player = player
                        avfoundationPlayback.addObservers()

                        NotificationCenter.default.post(
                            name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                            object: player.currentItem
                        )

                        expect(avfoundationPlayback.bitrate).toEventually(equal(7.0))
                    }
                }

                context("with new observedBitrate value") {
                    it("changes the bandwidth") {
                        let options = [
                            kSourceUrl: "http://clappr.io/highline.mp4"
                        ]
                        let avfoundationPlayback = AVFoundationPlayback(options: options)
                        let accessLog = AccessLogEventMock()
                        accessLog.setObservedBitrate(13.0)
                        let player = PlayerMock(accessLogEvent: accessLog)
                        avfoundationPlayback.player = player
                        avfoundationPlayback.addObservers()

                        NotificationCenter.default.post(
                            name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                            object: player.currentItem
                        )

                        expect(avfoundationPlayback.bandwidth).toEventually(equal(13.0))
                    }
                }

                context("with new numberOfDroppedVideoFrames value") {
                    it("changes the droppedFrames") {
                        let options = [
                            kSourceUrl: "http://clappr.io/highline.mp4"
                        ]
                        let avfoundationPlayback = AVFoundationPlayback(options: options)
                        let accessLog = AccessLogEventMock()
                        accessLog.setDroppedFrames(2)
                        let player = PlayerMock(accessLogEvent: accessLog)
                        avfoundationPlayback.player = player
                        avfoundationPlayback.addObservers()

                        NotificationCenter.default.post(
                            name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                            object: player.currentItem
                        )

                        expect(avfoundationPlayback.droppedFrames).toEventually(equal(2))
                    }
                }
            }

            context("when call play") {
                it("makes available domain host") {
                    let options = [
                        kSourceUrl: "http://clappr.io/highline.mp4"
                    ]
                    let avfoundationPlayback = AVFoundationPlayback(options: options)

                    avfoundationPlayback.play()

                    expect(avfoundationPlayback.domainHost).to(equal("clappr.io"))
                }

                it("makes available the decoded frames value") {
                    let options = [
                        kSourceUrl: "http://clappr.io/highline.mp4"
                    ]
                    let avfoundationPlayback = AVFoundationPlayback(options: options)

                    avfoundationPlayback.play()

                    expect(avfoundationPlayback.decodedFrames).toEventually(equal(-1))
                }
            }
        }
    }
}
