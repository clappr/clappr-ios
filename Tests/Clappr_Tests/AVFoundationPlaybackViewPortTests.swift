import Quick
import Nimble

@testable import Clappr

class AVFoundationPlaybackViewPortTests: QuickSpec {

    override func spec() {
        describe("AVFoundationPlaybackViewPort") {
            if #available(iOS 11.0, *) {
                context("#setupMaxResolution") {
                    it("sets preferredMaximumResolution according to the size") {
                        let playback = AVFoundationPlayback()
                        playback.player = AVPlayerStub()
                        let expectedSize = CGSize(width: 200, height: 200)

                        playback.setupMaxResolution(for: expectedSize)

                        expect(playback.player?.currentItem?.preferredMaximumResolution).to(equal(expectedSize))
                    }
                }
            }
        }
    }
}

