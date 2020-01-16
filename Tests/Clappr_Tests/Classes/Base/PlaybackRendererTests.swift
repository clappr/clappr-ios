import Quick
import Nimble
@testable import Clappr

class PlaybackRendererTests: QuickSpec {

    override func spec() {
        describe("PlaybackRenderer") {
            it("should play video when in chromeless mode") {
                let playback = StubPlayback(options: [kChromeless: true])
                let playbackRenderer = PlaybackRenderer()
                
                playbackRenderer.render(playback: playback)
                
                expect(playback.didCallPlay).toEventually(beTrue())
            }
            
            it("should not play video when not in chromeless mode") {
                let playback = StubPlayback(options: [:])
                let playbackRenderer = PlaybackRenderer()
                
                playbackRenderer.render(playback: playback)
                
                expect(playback.didCallPlay).toEventually(beFalse())
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

