import Quick
import Nimble
import AVFoundation
import OHHTTPStubs
import AVKit

@testable import Clappr

class AVFoundationNowPlayingTests: QuickSpec {

    override func spec() {
        describe("AVFoundationNowPlaying Tests") {

            var asset: AVURLAssetStub!
            var item: AVPlayerItemStub!
            var player: AVPlayerStub!
            var playback: AVFoundationPlayback!
            var itemInfo: AVPlayerItemInfo!

            beforeEach {
                OHHTTPStubs.removeAllStubs()
                asset = AVURLAssetStub(url: URL(string: "https://www.google.com")!, options: nil)
                item = AVPlayerItemStub(asset: asset)

                player = AVPlayerStub()
                player.set(currentItem: item)

                playback = AVFoundationPlayback(options: [:])
                playback.player = player
                playback.render()
                itemInfo = AVPlayerItemInfo(item: item, delegate: playback)
                playback.itemInfo = itemInfo


                stub(condition: isHost("clappr.sample") || isHost("clappr.io")) { result in
                    if result.url?.path == "/master.m3u8" {
                        let stubPath = OHPathForFile("master.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: [:])
                    } else if result.url!.path.contains(".ts") {
                        let stubPath = OHPathForFile(result.url!.path.replacingOccurrences(of: "/", with: ""), type(of: self))
                        return fixture(filePath: stubPath!, headers: [:])
                    }

                    let stubPath = OHPathForFile("sample.m3u8", type(of: self))
                    return fixture(filePath: stubPath!, headers: [:])
                }
            }

            afterEach {
                playback.stop()
                itemInfo = nil
                asset = nil
                item = nil
                player = nil
                playback = nil
                itemInfo = nil
                OHHTTPStubs.removeAllStubs()
            }
            
            describe("#loadMetadata") {

                context("when avplayer has playerItem") {
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

                context("when avplayer has playerItem and is ready to play") {
                    it("calls loadMetadata") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let nowPlayingService = NowPlayingServiceStub()
                        playback = AVFoundationPlayback(options: options)
                        playback.nowPlayingService = nowPlayingService

                        playback.render()
                        playback.play()

                        expect(nowPlayingService.countOfCallsOfSetItems).toEventually(equal(1))
                    }
                }
            }

            describe("#playerViewController") {
                var avFoundationPlayback: AVFoundationPlayback!
                var controller: AVPlayerViewController!
                let fromTime = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
                let toTime = CMTimeMakeWithSeconds(10, preferredTimescale: Int32(NSEC_PER_SEC))

                beforeEach {
                    controller = AVPlayerViewController()

                    stub(condition: isHost("clappr.sample")) { _ in
                        let stubPath = OHPathForFile("sample.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"application/vnd.apple.mpegURL; charset=utf-8"])
                    }
                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "https://clappr.sample/sample.m3u8"])

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

                    it("triggers didSeek") {
                        waitUntil { done in
                            avFoundationPlayback.on(Event.didSeek.rawValue) { _ in
                                done()
                            }

                            _ = avFoundationPlayback.playerViewController(controller, willResumePlaybackAfterUserNavigatedFrom: fromTime, to: toTime)
                        }
                    }
                }

                context("when subtitle is selected") {
                    it("triggers subtitle selected event") {
                        waitUntil { done in
                            avFoundationPlayback.on(Event.didSelectSubtitle.rawValue) { _ in
                                done()
                            }

                            let group = avFoundationPlayback.player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic(rawValue: AVMediaCharacteristic.legible.rawValue))

                            let option = avFoundationPlayback.player?.currentItem?.currentMediaSelection.selectedMediaOption(in: group!)

                            _ = avFoundationPlayback.playerViewController(controller, didSelect: option, in: group!)
                        }
                    }
                }
            }
        }
    }
}
