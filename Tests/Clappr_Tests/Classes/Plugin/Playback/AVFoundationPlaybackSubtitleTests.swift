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

                        avfoundationPlayback.selectedSubtitle = MediaOption.mockedSubtitle

                        avfoundationPlayback.view.bounds = CGRect(x: 0, y: 0, width: 279, height: 155)

                        expect(avfoundationPlayback.selectedSubtitle?.language).to(equal("off"))
                    }
                }
            }
        }
    }
}
