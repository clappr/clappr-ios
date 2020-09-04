import Quick
import Nimble

@testable import Clappr

class AVFoundationPlaybackAudioTests: QuickSpec {
    override func spec() {
        describe(".AVFoundationPlaybackAudioTests") {
            describe("#localAsset") {
                context("when default audio is passed") {
                    it("changes the audio source") {
                        guard let pathAudio = Bundle(for: AVFoundationPlaybackTests.self).path(forResource: "sample", ofType: "movpkg") else {
                            fail("Could not load local sample")
                            return
                        }
                        let localURL = URL(fileURLWithPath: pathAudio)
                        let options = [kSourceUrl: localURL.absoluteString, kDefaultAudioSource: "por"]
                        let playback = AVFoundationPlayback(options: options)

                        playback.play()

                        expect(playback.audioSources?.first?.name).toEventually(equal("Portuguese"), timeout: 5)
                    }
                }
            }
        }
    }
}
