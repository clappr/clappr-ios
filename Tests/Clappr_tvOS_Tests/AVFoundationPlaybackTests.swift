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

            describe("#subtitleSelected") {

                var avFoundationPlayback: AVFoundationPlayback!

                beforeEach {
                    stub(condition: isHost("clappr.sample")) { _ in
                        let stubPath = OHPathForFile("sample.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"application/vnd.apple.mpegURL; charset=utf-8"])
                    }

                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "https://clappr.sample/sample.m3u8"])

                    avFoundationPlayback.play()
                }

                context("when playback does not have subtitles") {
                    it("returns nil for selected subtitle") {
                        let playback = AVFoundationPlayback()

                        expect(playback.selectedSubtitle).to(beNil())
                    }
                }

                context("when playback has subtitles") {
                    it("returns default subtitle for a playback with subtitles") {
                        expect(avFoundationPlayback.selectedSubtitle).toEventuallyNot(beNil())
                    }
                }

                context("when subtitle is selected") {
                    it("triggers subtitleSelected event") {
                        var subtitleOption: MediaOption?
                        avFoundationPlayback.on(Event.subtitleSelected.rawValue) { (userInfo: EventUserInfo) in
                            subtitleOption = userInfo?["mediaOption"] as? MediaOption
                        }

                        avFoundationPlayback.selectedSubtitle = avFoundationPlayback.subtitles?[0]

                        expect(subtitleOption).toEventuallyNot(beNil())
                        expect(subtitleOption).toEventually(beAKindOf(MediaOption.self))
                    }
                }
            }

            describe("#selectedAudioSource") {
                var playback: AVFoundationPlayback!

                beforeEach {
                    playback = AVFoundationPlayback()
                }

                it("returns nil for a playback without audio sources") {
                    expect(playback.selectedAudioSource).to(beNil())
                }

                context("when audio is selected") {
                    it("triggers audioSelected event") {
                        var audioSelected: MediaOption?
                        playback.on(Event.audioSelected.rawValue) { (userInfo: EventUserInfo) in
                            audioSelected = userInfo?["mediaOption"] as? MediaOption
                        }

                        playback.selectedAudioSource = MediaOption(name: "English", type: MediaOptionType.audioSource, language: "eng", raw: AVMediaSelectionOption())

                        expect(audioSelected).toEventuallyNot(beNil())
                        expect(audioSelected).to(beAKindOf(MediaOption.self))
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

                context("when subtitle is selected") {
                    it("triggers subtitle selected event") {
                        waitUntil { done in
                            avFoundationPlayback.on(Event.subtitleSelected.rawValue) { _ in
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

fileprivate class NowPlayingServiceStub: AVFoundationNowPlayingService {
    var countOfCallsOfSetItems = 0
    
    override func setItems(to playerItem: AVPlayerItem, with options: Options) {
        countOfCallsOfSetItems += 1
    }
}
