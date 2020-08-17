import Quick
import Nimble

@testable import Clappr

class AVFoundationPlaybackSubtitleTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackSubtitleTests") {
            describe("when turnOffSubtitle is called") {
                it("sets subtitle to off") {
                    let avfoundationPlayback = AVFoundationPlayback(options: [:])
                    avfoundationPlayback.player = PlayerMock()

                    avfoundationPlayback.turnOffSubtitle()

                    let playerItemMock = avfoundationPlayback.player?.currentItem as? PlayerItemMock
                    expect(playerItemMock?.mediaSelectionOptionMocked).to(equal(MediaOption.mockedSubtitle.avMediaSelectionOption))
                }
            }
        }
    }
}
