import Quick
import Nimble
import OHHTTPStubs
import AVFoundation
import Swifter

@testable import Clappr

class AVFoundationPlaybackTests: QuickSpec {

    override func spec() {
        describe("AVFoundationPlayback Tests") {

            let server = HTTPStub()

            beforeSuite {
                server.start()
            }

            afterSuite {
                server.stop()
            }

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

            if #available(iOS 11.0, *) {
                context("when did change bounds") {
                    it("sets preferredMaximumResolution according to playback bounds size") {
                        let playback = AVFoundationPlayback()
                        playback.player = AVPlayerStub()

                        playback.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)

                        expect(playback.player?.currentItem?.preferredMaximumResolution).to(equal(playback.bounds.size))
                    }
                }
            }

            describe("#isReadyToSeek") {
                context("when AVPlayer status is readyToPlay") {
                    it("returns true") {
                        let playback = AVFoundationPlayback()
                        let playerStub = AVPlayerStub()
                        playback.player = playerStub

                        playerStub.setStatus(to: .readyToPlay)

                        expect(playback.isReadyToSeek).to(beTrue())
                    }
                }

                context("when AVPlayer status is unknown") {

                    it("returns false") {
                        let playback = AVFoundationPlayback()
                        let playerStub = AVPlayerStub()
                        playback.player = playerStub

                        playerStub.setStatus(to: .unknown)

                        expect(playback.isReadyToSeek).to(beFalse())
                    }
                }

                context("when AVPlayer status is failed") {

                    it("returns false") {
                        let playback = AVFoundationPlayback()
                        let playerStub = AVPlayerStub()
                        playback.player = playerStub

                        playerStub.setStatus(to: .failed)

                        expect(playback.isReadyToSeek).to(beFalse())
                    }
                }
            }

            describe("#seek") {

                var avFoundationPlayback: AVFoundationPlayback!

                beforeEach {
                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "http://localhost:8080/sample.m3u8"])
                    avFoundationPlayback.play()
                }

                context("when AVPlayer status is readyToPlay") {

                    it("doesn't store the desired seek time") {
                        let playback = AVFoundationPlayback()
                        let player = AVPlayerStub()
                        player.setStatus(to: .readyToPlay)
                        playback.player = player

                        playback.seek(20)

                        expect(playback.seekToTimeWhenReadyToPlay).to(beNil())
                    }

                    it("calls seek right away") {
                        let playback = AVFoundationPlayback()
                        let player = AVPlayerStub()
                        player.setStatus(to: .readyToPlay)
                        playback.player = player

                        playback.seek(20)

                        expect(player._item.didCallSeekWithCompletionHandler).to(beTrue())
                    }
                }

                context("when AVPlayer status is not readyToPlay") {

                    it("stores the desired seek time") {
                        let playback = AVFoundationPlayback()

                        playback.seek(20)

                        expect(playback.seekToTimeWhenReadyToPlay).to(equal(20))
                    }

                    it("doesn't calls seek right away") {
                        let playback = AVFoundationPlayback()
                        let player = AVPlayerStub()
                        playback.player = player

                        player.setStatus(to: .unknown)
                        playback.seek(20)

                        expect(player._item.didCallSeekWithCompletionHandler).to(beFalse())
                    }
                }

                describe("#seekIfNeeded") {

                    context("when seekToTimeWhenReadyToPlay is nil") {
                        it("doesnt perform a seek") {
                            let playback = AVFoundationPlayback()
                            let player = AVPlayerStub()
                            playback.player = player
                            player.setStatus(to: .readyToPlay)

                            playback.seekOnReadyIfNeeded()

                            expect(player._item.didCallSeekWithCompletionHandler).to(beFalse())
                            expect(playback.seekToTimeWhenReadyToPlay).to(beNil())
                        }
                    }

                    context("when seekToTimeWhenReadyToPlay is not nil") {
                        it("does perform a seek") {
                            let playback = AVFoundationPlayback()
                            let player = AVPlayerStub()
                            playback.player = player
                            player.setStatus(to: .unknown)

                            playback.seek(20)
                            player.setStatus(to: .readyToPlay)
                            playback.seekOnReadyIfNeeded()

                            expect(player._item.didCallSeekWithCompletionHandler).to(beTrue())
                            expect(playback.seekToTimeWhenReadyToPlay).to(beNil())
                        }
                    }
                }

                it("triggers willSeek event") {
                    waitUntil(timeout: 3) { done in
                        let listener = BaseObject()

                        listener.listenTo(avFoundationPlayback, eventName: Event.willSeek.rawValue) { info in
                            done()
                        }

                        avFoundationPlayback.seek(5)
                    }
                }

                it("triggers seek event") {
                    waitUntil(timeout: 3) { done in
                        let listener = BaseObject()

                        listener.listenTo(avFoundationPlayback, eventName: Event.seek.rawValue) { info in
                            done()
                        }

                        avFoundationPlayback.seek(5)
                    }
                }

                it("triggers didSeek when a seek is completed") {
                    waitUntil(timeout: 3) { done in
                        let listener = BaseObject()

                        listener.listenTo(avFoundationPlayback, eventName: Event.didSeek.rawValue) { info in
                            done()
                        }

                        avFoundationPlayback.seek(5)
                    }
                }

                it("triggers positionUpdate for the desired position") {
                    waitUntil(timeout: 3) { done in
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

        class AVPlayerStub: AVPlayer {

            override var currentItem: AVPlayerItem? {
                return _item
            }

            var _item = AVPlayerItemMock(url: URL(string: "https://clappr.io/highline.mp4")!)

            func setStatus(to newStatus: AVPlayerItemStatus) {
                _item._status = newStatus
            }
        }

        class AVPlayerItemMock: AVPlayerItem {

            override var status: AVPlayerItemStatus {
                return _status
            }

            var didCallSeekWithCompletionHandler = false

            var _status: AVPlayerItemStatus = AVPlayerItemStatus.unknown

            override func seek(to time: CMTime, completionHandler: ((Bool) -> Void)?) {
                didCallSeekWithCompletionHandler = true
            }
        }

    }
}
