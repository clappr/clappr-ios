import Quick
import Nimble
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackQualityMetricsTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackQualityMetricsTests") {
            
            var avFoundationPlayback: AVFoundationPlayback!
            var accessLog: AccessLogEventMock!
            
            context("when receives AVPlayerItemNewAccessLogEntry event") {
                
                beforeEach {
                    avFoundationPlayback = AVFoundationPlayback(options: [:])
                    avFoundationPlayback.render()
                    accessLog = AccessLogEventMock()
                }
                
                context("with new indicatedBitrate value") {
                    it("changes the bitrate") {
                        let baseObject = BaseObject()
                        var bitrate: Double?
                        let player = PlayerMock(accessLogEvent: accessLog)
                        accessLog.setIndicatedBitrate(7)
                        avFoundationPlayback.player = player
                        baseObject.listenToOnce(avFoundationPlayback, eventName: Event.didUpdateBitrate.rawValue) { userInfo in
                            bitrate = userInfo?["bitrate"] as? Double
                        }

                        avFoundationPlayback.onAccessLogEntry(notification: nil)
                        
                        expect(bitrate).toEventually(equal(7))
                    }
                }
                
                context("with new observedBitrate value") {
                    it("changes the bandwidth") {
                        accessLog.setObservedBitrate(13.0)
                        let player = PlayerMock(accessLogEvent: accessLog)
                        avFoundationPlayback.player = player

                        NotificationCenter.default.post(
                            name: .AVPlayerItemNewAccessLogEntry,
                            object: player.currentItem
                        )

                        expect(avFoundationPlayback.bandwidth).toEventually(equal(13.0))
                    }
                }

                describe("droppedFrames") {
                    context("with new numberOfDroppedVideoFrames value") {
                        it("changes the droppedFrames") {
                            accessLog.setDroppedFrames(2)
                            let player = PlayerMock(accessLogEvent: accessLog)
                            avFoundationPlayback.player = player
                            
                            NotificationCenter.default.post(
                                name: .AVPlayerItemNewAccessLogEntry,
                                object: player.currentItem
                            )
                            
                            expect(avFoundationPlayback.droppedFrames).toEventually(equal(2))
                        }
                        
                        context("when occurs another AVPlayerItemNewAccessLogEntry event") {
                            it("changes the droppedFrames to an accumulated value") {
                                accessLog.setDroppedFrames(2)
                                let player = PlayerMock(accessLogEvent: accessLog)
                                avFoundationPlayback.player = player
                                
                                NotificationCenter.default.post(
                                    name: .AVPlayerItemNewAccessLogEntry,
                                    object: player.currentItem
                                )
                                
                                accessLog.setDroppedFrames(3)
                                
                                NotificationCenter.default.post(
                                    name: .AVPlayerItemNewAccessLogEntry,
                                    object: player.currentItem
                                )
                                
                                expect(avFoundationPlayback.droppedFrames).toEventually(equal(5))
                            }
                            
                            context("when value is negative") {
                                it("doesn't change the droppedFrames accumulated value") {
                                    accessLog.setDroppedFrames(31)
                                    let player = PlayerMock(accessLogEvent: accessLog)
                                    avFoundationPlayback.player = player
                                    
                                    NotificationCenter.default.post(
                                        name: .AVPlayerItemNewAccessLogEntry,
                                        object: player.currentItem
                                    )
                                    
                                    accessLog.setDroppedFrames(-1)
                                    
                                    NotificationCenter.default.post(
                                        name: .AVPlayerItemNewAccessLogEntry,
                                        object: player.currentItem
                                    )
                                    
                                    expect(avFoundationPlayback.droppedFrames).toEventually(equal(31))
                                }
                            }
                        }
                    }
                    
                    context("when call stop") {
                        it("clears droppedFrames value") {
                            accessLog.setDroppedFrames(24)
                            let player = PlayerMock(accessLogEvent: accessLog)
                            avFoundationPlayback.player = player

                            NotificationCenter.default.post(
                                name: .AVPlayerItemNewAccessLogEntry,
                                object: player.currentItem
                            )
                            avFoundationPlayback.state = .playing
                            
                            avFoundationPlayback.stop()
                            
                            expect(avFoundationPlayback.droppedFrames).toEventually(equal(0))
                        }
                    }
                    
                    context("when playback did end") {
                        it("clears droppedFrames value") {
                            accessLog.setDroppedFrames(76)
                            let player = PlayerMock(accessLogEvent: accessLog, isFinished: true)
                            avFoundationPlayback.player = player
                            
                            NotificationCenter.default.post(
                                name: .AVPlayerItemNewAccessLogEntry,
                                object: nil
                            )

                            NotificationCenter.default.post(
                                name: .AVPlayerItemDidPlayToEndTime,
                                object: player.currentItem
                            )
                            
                            expect(avFoundationPlayback.droppedFrames).toEventually(equal(0))
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

                    avFoundationPlayback = AVFoundationPlayback(options: options)
                    avFoundationPlayback.render()

                    expect(avFoundationPlayback.domainHost).toEventually(equal("clappr.io"))
                }

                it("makes available the decoded frames value") {
                    let options = [
                        kSourceUrl: "http://clappr.io/highline.mp4"
                    ]

                    avFoundationPlayback = AVFoundationPlayback(options: options)
                    avFoundationPlayback.render()

                    expect(avFoundationPlayback.decodedFrames).toEventually(equal(-1))
                }
            }
        }
    }
}
