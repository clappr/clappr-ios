import Quick
import Nimble
import Clappr

class PlaybackTests: QuickSpec {
    
    override func spec() {
        describe("Playback") {
            var playback: Playback!
            let sourceURL = NSURL(string: "http://globo.com/video.mp4")!
            
            beforeEach() {
                playback = Playback(url: sourceURL)
            }
            
            it("Should have a play method") {
                let responds = playback.respondsToSelector("play")
                expect(responds).to(beTrue())
            }
            
            it("Should have a pause method") {
                let responds = playback.respondsToSelector("pause")
                expect(responds).to(beTrue())
            }
            
            it("Should have a stop method") {
                let responds = playback.respondsToSelector("stop")
                expect(responds).to(beTrue())
            }
        }
    }
}
