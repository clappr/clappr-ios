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

                describe("droppedFrames") {
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
                        
                        context("when occurs another AVPlayerItemNewAccessLogEntry event") {
                            it("changes the droppedFrames to an accumulated value") {
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
                                
                                expect(avfoundationPlayback.droppedFrames).toEventually(equal(5))
                            }
                            
                            context("when value is negative") {
                                it("doesn't change the droppedFrames accumulated value") {
                                    let avfoundationPlayback = AVFoundationPlayback(options: [:])
                                    let accessLog = AccessLogEventMock()
                                    accessLog.setDroppedFrames(31)
                                    let player = PlayerMock(accessLogEvent: accessLog)
                                    avfoundationPlayback.player = player
                                    avfoundationPlayback.addObservers()
                                    
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                        object: player.currentItem
                                    )
                                    
                                    accessLog.setDroppedFrames(-1)
                                    
                                    NotificationCenter.default.post(
                                        name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                        object: player.currentItem
                                    )
                                    
                                    expect(avfoundationPlayback.droppedFrames).toEventually(equal(31))
                                }
                            }
                        }
                    }
                    
                    context("when call stop") {
                        it("clears droppedFrames value") {
                            let avfoundationPlayback = AVFoundationPlayback(options: [:])
                            let accessLog = AccessLogEventMock()
                            accessLog.setDroppedFrames(24)
                            let player = PlayerMock(accessLogEvent: accessLog)
                            avfoundationPlayback.player = player
                            avfoundationPlayback.addObservers()
                            NotificationCenter.default.post(
                                name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                object: player.currentItem
                            )
                            
                            avfoundationPlayback.stop()
                            
                            expect(avfoundationPlayback.droppedFrames).toEventually(equal(0))
                        }
                    }
                    
                    context("when playback did end") {
                        it("clears droppedFrames value") {
                            let avfoundationPlayback = AVFoundationPlayback(options: [:])
                            let accessLog = AccessLogEventMock()
                            accessLog.setDroppedFrames(76)
                            let player = PlayerMock(accessLogEvent: accessLog, isFinished: true)
                            avfoundationPlayback.player = player
                            avfoundationPlayback.addObservers()
                            
                            NotificationCenter.default.post(
                                name: .AVPlayerItemNewAccessLogEntry,
                                object: nil
                            )

                            NotificationCenter.default.post(
                                name: .AVPlayerItemDidPlayToEndTime,
                                object: player.currentItem
                            )
                            
                            expect(avfoundationPlayback.droppedFrames).toEventually(equal(0))
                        }
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
