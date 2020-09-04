import Quick
import Nimble

@testable import Clappr

class AVFoundationPlaybackSubtitleTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackSubtitleTests") {
            describe("#hideSubtitleForSmallScreen") {
                context("when view is resized to a size smaller than 280x156") {
                    it("sets subtitle to off") {
                        let avfoundationPlayback = AVFoundationPlayback(options: [:])
                        avfoundationPlayback.player = PlayerMock()
                        avfoundationPlayback.setupObservers()

                        avfoundationPlayback.selectedSubtitle = MediaOption.mockedSubtitle

                        avfoundationPlayback.view.bounds = CGRect(x: 0, y: 0, width: 279, height: 155)

                        expect(avfoundationPlayback.selectedSubtitle?.language).to(equal("off"))
                    }
                }
            }

            describe("#localAsset") {
                context("when default subtitle is passed") {
                    it("changes subtitle source") {
                        guard let path = Bundle(for: AVFoundationPlaybackTests.self).path(forResource: "sample", ofType: "movpkg") else {
                            fail("Could not load local sample")
                            return
                        }
                        let localURL = URL(fileURLWithPath: path)
                        let options = [kSourceUrl: localURL.absoluteString, kDefaultSubtitle: "pt"]
                        let playback = AVFoundationPlayback(options: options)

                        playback.play()

                        expect(playback.subtitles?.first?.name).toEventually(equal("Portuguese"), timeout: 5)
                    }
                }
            }
        }
    }
}

