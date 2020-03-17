import Quick
import Nimble
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackQualityMetricsTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackQualityMetricsTests") {
            context("when receives AVPlayerItemNewAccessLogEntry event") {
                context("with new indicatedBitrate value") {
                    it("changes the bitrate") {
                        let baseObject = BaseObject()
                        var bitrate: Double?
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
                        let accessLog = AccessLogEventMock()
                        let player = PlayerMock(accessLogEvent: accessLog)
                        accessLog.setIndicatedBitrate(7)
                        avfoundationPlayback.player = player
                        baseObject.listenToOnce(avfoundationPlayback, eventName: Event.didUpdateBitrate.rawValue) { userInfo in
                            bitrate = userInfo?["bitrate"] as? Double
                        }

                        avfoundationPlayback.onAccessLogEntry(notification: nil)
                        
                        expect(bitrate).toEventually(equal(7))
                    }
                }
                
                context("with new observedBitrate value") {
                    it("changes the bandwidth") {
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
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
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
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

                    it("changes the totalOfDroppedFrames") {
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
                        let accessLog = AccessLogEventMock()
                        accessLog.setDroppedFrames(2)
                        let player = PlayerMock(accessLogEvent: accessLog)
                        avfoundationPlayback.player = player
                        avfoundationPlayback.addObservers()

                        NotificationCenter.default.post(
                            name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                            object: player.currentItem
                        )

                        accessLog.setDroppedFrames(3)

                        NotificationCenter.default.post(
                            name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                            object: player.currentItem
                        )

                        expect(avfoundationPlayback.totalOfDroppedFrames).toEventually(equal(5))
                    }
                }
            }

            context("when call play") {
                var stubsDescriptor: OHHTTPStubsDescriptor?

                beforeEach {
                    OHHTTPStubs.removeAllStubs()

                    stubsDescriptor = stub(condition: isAbsoluteURLString("http://clappr.io/highline.mp4")) { _ in
                        return fixture(filePath: "", headers: [:])
                    }
                    
                    stubsDescriptor?.name = "StubToHighlineVideo.mp4"
                }

                afterEach {
                    OHTTPStubsHelper.removeStub(with: stubsDescriptor)
                }

                it("makes available domain host") {
                    let options = [
                        kSourceUrl: "http://clappr.io/highline.mp4"
                    ]

                    let avfoundationPlayback = AVFoundationPlayback(options: options)

                    expect(avfoundationPlayback.domainHost).toEventually(equal("clappr.io"))
                }

                it("makes available the decoded frames value") {
                    let options = [
                        kSourceUrl: "http://clappr.io/highline.mp4"
                    ]

                    let avfoundationPlayback = AVFoundationPlayback(options: options)

                    expect(avfoundationPlayback.decodedFrames).toEventually(equal(-1))
                }
            }
        }
    }
}
