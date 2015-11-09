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
            
            it("Should have a seek method receiving a time") {
                let responds = playback.respondsToSelector("seekTo:")
                expect(responds).to(beTrue())
            }
            
            it("Should have a duration function with a default value 0") {
                expect(playback.duration()) == 0
            }
            
            it("Should have a isPlaying function with a default value false") {
                expect(playback.isPlaying()).to(beFalse())
            }
            
            it("Should have a type function with a default value Unknown") {
                expect(playback.type()).to(equal(ClapprPlaybackType.Unknown))
            }

            it("Should have a isHighDefinitionInUse function with a default value false") {
                expect(playback.isHighDefinitionInUse()).to(beFalse())
            }
            
            it("Should be removed from superview when destroy is called") {
                let container = UIView()
                container.addSubview(playback)
                
                expect(playback.superview).toNot(beNil())
                playback.destroy()
                expect(playback.superview).to(beNil())
            }
            
            it("Should stop listening events after destroy has been called") {
                var callbackWasCalled = false
                
                playback.on("some-event") { userInfo in
                    callbackWasCalled = true
                }
                
                playback.destroy()
                playback.trigger("some-event")
                
                expect(callbackWasCalled) == false
            }
            
            it("Should have a class function to check if a source can be played with default value false") {
                let canPlay = Playback.canPlay(NSURL())
                expect(canPlay) == false
            }
        }
    }
}
