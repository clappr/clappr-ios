import Quick
import Nimble
import AVFoundation
import AVKit
import OHHTTPStubs
@testable import Clappr

class AVFoundationPlaybackTests: QuickSpec {

    override func spec() {
        describe("AVFoundationPlayback") {

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

            describe("#loadMetadata") {

                func getPlayback(with source: String) -> AVFoundationPlayback {
                    let asset = AVAsset(url: URL(string: source)!)
                    let playerItem = AVPlayerItem(asset: asset)

                    let playback = AVFoundationPlayback(options: [kSourceUrl: source])
                    playback.player = AVPlayer(playerItem: playerItem)
                    return playback
                }

                context("when avplayer has playerItem") {

                    let playback = getPlayback(with: "https://clappr.io/highline.mp4")

                    it("calls setItemsToPlayerItem of AVFoundationNowPlaying") {
                        let nowPlayingService = NowPlayingServiceStub()
                        playback.nowPlayingService = nowPlayingService

                        playback.loadMetadata()

                        expect(nowPlayingService.countOfCallsOfSetItems).toEventually(equal(1))
                    }
                }

                context("when AVPlayer don't have playerItem") {

                    let playback = AVFoundationPlayback(options: [:])

                    it("doesn't call setItemsToPlayerItem of AVFoundationNowPlaying") {
                        let nowPlayingService = NowPlayingServiceStub()
                        playback.nowPlayingService = nowPlayingService

                        playback.loadMetadata()

                        expect(nowPlayingService.countOfCallsOfSetItems).toEventually(equal(0))
                    }
                }
            }

            describe("#playerViewController") {
                var avFoundationPlayback: AVFoundationPlayback!
                var controller: AVPlayerViewController!
                let fromTime = CMTimeMakeWithSeconds(0, Int32(NSEC_PER_SEC))
                let toTime = CMTimeMakeWithSeconds(10, Int32(NSEC_PER_SEC))

                beforeEach {
                    controller = AVPlayerViewController()

                    stub(condition: isHost("clappr.io")) { _ in
                        let stubPath = OHPathForFile("video.mp4", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"video/mp4"])
                    }
                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "https://clappr.io/highline.mp4"])

                    avFoundationPlayback.play()
                }

                context("when seek will begin") {
                    it("triggers will seek") {
                        waitUntil { done in
                            avFoundationPlayback.on(Event.willSeek.rawValue) { _ in
                                done()
                            }

                            _ = avFoundationPlayback.playerViewController(controller, timeToSeekAfterUserNavigatedFrom: fromTime, to: toTime)
                        }
                    }
                }

                context("when seek is executed") {
                    it("triggers seek") {
                        waitUntil { done in
                            avFoundationPlayback.on(Event.seek.rawValue) { _ in
                                done()
                            }

                            _ = avFoundationPlayback.playerViewController(controller, willResumePlaybackAfterUserNavigatedFrom: fromTime, to: toTime)
                        }
                    }

                    it("triggers didSeek") {
                        waitUntil { done in
                            avFoundationPlayback.on(Event.didSeek.rawValue) { _ in
                                done()
                            }

                            _ = avFoundationPlayback.playerViewController(controller, willResumePlaybackAfterUserNavigatedFrom: fromTime, to: toTime)
                        }
                    }
                }
            }
        }
    }
}

fileprivate class NowPlayingServiceStub: AVFoundationNowPlayingService {
    var countOfCallsOfSetItems = 0
    
    override func setItems(to playerItem: AVPlayerItem, with options: Options) {
        countOfCallsOfSetItems += 1
    }
}
