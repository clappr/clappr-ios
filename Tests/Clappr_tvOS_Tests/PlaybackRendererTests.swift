import Quick
import Nimble
@testable import Clappr

class PlaybackRendererTests: QuickSpec {
    override func spec() {
        describe("PlaybackRenderer") {
            it("should play video") {
                let playback = StubPlayback(options: [:])
                let playbackRenderer = PlaybackRenderer()
                
                playbackRenderer.render(playback: playback)
                
                expect(playback.didCallPlay).toEventually(beTrue())
            }
        }
    }
    
    class StubPlayback: Playback {
        var didCallPlay = false
        
        override func play() {
            didCallPlay = true
        }
    }
}

