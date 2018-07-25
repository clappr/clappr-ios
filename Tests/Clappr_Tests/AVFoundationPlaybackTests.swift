import Quick
import Nimble
import AVFoundation
import Swifter
import OHHTTPStubs

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

            describe("AVFoundationPlaybackExtension") {
                var asset: AVURLAssetStub!
                var item: AVPlayerItemStub!
                var player: AVPlayerStub!
                var playback: AVFoundationPlayback!

                beforeEach {
                    asset = AVURLAssetStub(url: URL(string: "https://www.google.com")!, options: nil)
                    item = AVPlayerItemStub(asset: asset)

                    player = AVPlayerStub()
                    player.set(currentItem: item)

                    playback = AVFoundationPlayback()
                    playback.player = player
                }

                describe("#minDvrSize") {
                    context("when minDvrOption has correct type value") {
                        it("return minDvrOption value") {
                            let options = [kMinDvrSize: 15.1]
                            let playback = AVFoundationPlayback(options: options)

                            expect(playback.minDvrSize).to(equal(15.1))
                        }
                    }
                    context("when minDvrOption has wrong type value") {
                        it("return default value") {
                            let options = [kMinDvrSize: 15]
                            let playback = AVFoundationPlayback(options: options)

                            expect(playback.minDvrSize).to(equal(60))
                        }
                    }
                    context("when minDvrOption has no value") {
                        it("returns default value") {
                            expect(playback.minDvrSize).to(equal(60))
                        }
                    }
                }

                describe("#usingDVR") {
                    context("when video is vod") {
                        it("returns false") {
                            asset.set(duration: CMTime(seconds: 60, preferredTimescale: 1))

                            expect(playback.usingDVR).to(beFalse())
                        }
                    }

                    context("when video is live") {

                        beforeEach {
                            asset.set(duration: kCMTimeIndefinite)
                        }

                        context("video has dvr") {
                            context("when dvr is being used") {
                                it("triggers usinDVR with enabled true") {
                                    player.set(currentTime: CMTime(seconds: 59, preferredTimescale: 1))
                                    item.setSeekableTimeRange(with: 60)
                                    var usingDVR: Bool?
                                    playback.on(Event.usingDVR.rawValue) { info in
                                        if let enabled = info?["enabled"] as? Bool {
                                            usingDVR = enabled
                                        }
                                    }

                                    player.setStatus(to: .readyToPlay)
                                    playback.seek(50)

                                    expect(usingDVR).toEventually(beTrue())
                                }
                            }

                            context("when dvr is not being used") {
                                it("triggers usinDVR with enabled false") {
                                    player.set(currentTime: CMTime(seconds: 60, preferredTimescale: 1))
                                    item.setSeekableTimeRange(with: 60)
                                    var usingDVR: Bool?
                                    playback.on(Event.usingDVR.rawValue) { info in
                                        if let enabled = info?["enabled"] as? Bool {
                                            usingDVR = enabled
                                        }
                                    }

                                    player.setStatus(to: .readyToPlay)
                                    playback.seek(60)

                                    expect(usingDVR).toEventually(beFalse())
                                }
                            }
                        }

                        context("whe video does not have dvr") {
                            it("doesn't trigger usingDVR event") {
                                player.set(currentTime: CMTime(seconds: 59, preferredTimescale: 1))
                                var usingDVR: Bool?
                                playback.on(Event.usingDVR.rawValue) { info in
                                    if let enabled = info?["enabled"] as? Bool {
                                        usingDVR = enabled
                                    }
                                }

                                player.setStatus(to: .readyToPlay)
                                playback.seek(60)

                                expect(usingDVR).toEventually(beNil())
                            }
                        }
                    }
                }

                describe("#seekableTimeRanges") {
                    context("when player is nil") {
                        it("is empty") {
                            playback.player = nil

                            expect(playback.seekableTimeRanges).to(beEmpty())
                        }
                    }

                    context("when video has seekableTimeRanges") {
                        it("returns an array with NSValue") {
                            item.setSeekableTimeRange(with: 60)

                            expect(playback.seekableTimeRanges).toNot(beEmpty())
                        }
                    }
                    context("when video does not have seekableTimeRanges") {
                        it("is empty") {
                            expect(playback.seekableTimeRanges).to(beEmpty())
                        }
                    }
                }

                describe("#loadedTimeRanges") {
                    context("when player is nil") {
                        it("is empty") {
                            playback.player = nil

                            expect(playback.loadedTimeRanges).to(beEmpty())
                        }
                    }

                    context("when video has loadedTimeRanges") {
                        it("returns an array with NSValue") {
                            item.setLoadedTimeRanges(with: 60)

                            expect(playback.loadedTimeRanges).toNot(beEmpty())
                        }
                    }
                    context("when video does not have loadedTimeRanges") {
                        it("is empty") {
                            expect(playback.loadedTimeRanges).to(beEmpty())
                        }
                    }
                }

                describe("#supportDVR") {
                    context("when video is vod") {
                        it("returns false") {
                            asset.set(duration: CMTime(seconds: 60, preferredTimescale: 1))

                            expect(playback.supportDVR).to(beFalse())
                        }
                    }

                    context("when video is live") {
                        it("returns true") {
                            asset.set(duration: kCMTimeIndefinite)
                            item.setSeekableTimeRange(with: 60)

                            expect(playback.supportDVR).to(beTrue())
                        }
                    }
                }

                describe("#dvrPosition") {
                    it("returns the position inside the DVR window") {
                        asset.set(duration: CMTime(seconds: 50, preferredTimescale: 1))
                        item._currentTime = CMTime(seconds: 125, preferredTimescale: 1)
                        item.setWindow(start: 100, end: 150)

                        expect(playback.dvrPosition).to(equal(25))
                    }
                }

                describe("#currentDate") {
                    it("returns the currentDate of the video") {
                        let date = Date()
                        item.set(currentDate: date)
                        
                        expect(playback.currentDate).to(equal(date))
                    }
                }
            }

            describe("#duration") {
                var asset: AVURLAssetStub!
                var item: AVPlayerItemStub!
                var player: AVPlayerStub!
                var playback: AVFoundationPlayback!

                beforeEach {
                    asset = AVURLAssetStub(url: URL(string: "https://www.google.com")!, options: nil)
                    item = AVPlayerItemStub(asset: asset)

                    player = AVPlayerStub()
                    player.set(currentItem: item)

                    playback = AVFoundationPlayback()
                    playback.player = player
                }

                context("when video is vod") {
                    it("returns different from zero") {
                        asset.set(duration: CMTime(seconds: 60, preferredTimescale: 1))
                        player.set(currentItem: item)

                        player.setStatus(to: .readyToPlay)

                        expect(playback.duration) == 60
                    }
                }
                context("when video is live") {
                    context("when has dvr enabled") {
                        it("returns different from zero") {
                            asset.set(duration: kCMTimeIndefinite)
                            item.setSeekableTimeRange(with: 60)

                            player.setStatus(to: .readyToPlay)

                            expect(playback.duration) == 60
                        }
                    }
                    context("when doesn't have dvr enabled") {
                        it("returns zero") {
                            asset.set(duration: kCMTimeIndefinite)
                            player.setStatus(to: .readyToPlay)

                            expect(playback.duration) == 0
                        }
                    }
                }
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
                        let playerSize = playback.bounds.size
                        let mainScale = UIScreen.main.scale
                        let screenSize = CGSize(width: playerSize.width * mainScale, height: playerSize.height * mainScale)

                        expect(playback.player?.currentItem?.preferredMaximumResolution).to(equal(screenSize))
                    }
                }

                context("when setups avplayer") {

                    beforeEach {
                        stub(condition: isHost("clappr.io")) { _ in
                            let stubPath = OHPathForFile("video.mp4", type(of: self))
                            return fixture(filePath: stubPath!, headers: ["Content-Type":"video/mp4"])
                        }
                    }

                    it("sets preferredMaximumResolution according to playback bounds size") {
                        let playback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.io/slack.mp4"])
                        playback.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
                        let playerSize = playback.bounds.size
                        let mainScale = UIScreen.main.scale
                        let screenSize = CGSize(width: playerSize.width * mainScale, height: playerSize.height * mainScale)

                        playback.play()

                        expect(playback.player?.currentItem?.preferredMaximumResolution).toEventually(equal(screenSize))
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

            context("when sets a kvo on player") {

                class KVOStub: NSObject {

                    var didObserveValue = false
                    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                        didObserveValue = true
                    }
                }

                beforeEach {
                    stub(condition: isHost("clappr.io")) { _ in
                        let stubPath = OHPathForFile("video.mp4", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"video/mp4"])
                    }
                }

                it("works properly") {
                    let observer = KVOStub()
                    let playback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.io/slack.mp4"])

                    playback.addObserver(observer, forKeyPath: "player", options: [.old, .new], context: nil)
                    playback.play()

                    expect(observer.didObserveValue).toEventually(beTrue())
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
                    let playback = AVFoundationPlayback()
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var didTriggerWillSeek = false
                    playback.on(Event.willSeek.rawValue) { _ in
                        didTriggerWillSeek = true
                    }

                    playback.seek(5)

                    expect(didTriggerWillSeek).to(beTrue())
                }

                it("triggers seek event") {
                    let playback = AVFoundationPlayback()
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var didTriggerSeek = false
                    playback.on(Event.seek.rawValue) { _ in
                        didTriggerSeek = true
                    }

                    playback.seek(5)

                    expect(didTriggerSeek).to(beTrue())
                }

                it("triggers didSeek when a seek is completed") {
                    let playback = AVFoundationPlayback()
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var didTriggerDidSeek = false
                    playback.on(Event.didSeek.rawValue) { _ in
                        didTriggerDidSeek = true
                    }

                    playback.seek(5)

                    expect(didTriggerDidSeek).to(beTrue())
                }

                it("triggers positionUpdate for the desired position") {
                    let playback = AVFoundationPlayback()
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var updatedPosition: Float64? = nil
                    playback.on(Event.positionUpdate.rawValue) { (userInfo: EventUserInfo) in
                        updatedPosition = userInfo!["position"] as? Float64
                    }

                    playback.seek(5)

                    expect(updatedPosition).to(equal(5))
                }
            }
        }
    }
}
