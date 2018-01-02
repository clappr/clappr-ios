import Quick
import Nimble
import AVFoundation
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

            context("when player is ready to play") {

                var avFoundationPlayback: AVFoundationPlayback!

                beforeEach {
                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"])
                }

                context("and avplayer has playerItem") {

                    var nowPlayingService: NowPlayingServiceStub!

                    beforeEach {
                        nowPlayingService = NowPlayingServiceStub()
                        avFoundationPlayback.nowPlayingService = nowPlayingService
                        avFoundationPlayback.play()
                    }

                    it("calls setItemsToPlayerItem of AVFoundationNowPlaying") {
                        expect(nowPlayingService.didCallSetItems).toEventually(beTrue(), timeout: 10)
                    }
                }
            }
        }
    }
}

fileprivate class NowPlayingServiceStub: AVFoundationNowPlayingService {
    var didCallSetItems = false
    
    override func setItems(to playerItem: AVPlayerItem, with options: Options) {
        didCallSetItems = true
    }
}
