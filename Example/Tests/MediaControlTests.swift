import Quick
import Nimble
import Clappr

class MediaControlTests: QuickSpec {
    
    override func spec() {
        describe("MediaControl") {
            let sourceUrl = NSURL(string: "http://globo.com/video.mp4")!
            var container: Container!
            
            beforeEach() {
                container = Container(playback: Playback(url: sourceUrl))
            }
            
            context("Initialization") {
                
                it("Should have a init method that receives a container") {
                    let mediaControl = MediaControl.initWithContainer(container)
                    
                    expect(mediaControl).toNot(beNil())
                    expect(mediaControl.container) == container
                }
            }
            
            context("Behavior") {
                var mediaControl: MediaControl!
                
                beforeEach() {
                    mediaControl = MediaControl.initWithContainer(container)
                }
                
                context("Visibility") {
                    it("Should start with controls visible") {
                        expect(mediaControl.playPauseButton.hidden).to(beFalse())
                        expect(mediaControl.controlsOverlayView.hidden).to(beFalse())
                        expect(mediaControl.controlsWrapperView.hidden).to(beFalse())
                    }
                    
                    it("Should hide it's control after hide is called") {
                        mediaControl.hide()
                        
                        expect(mediaControl.playPauseButton.hidden).to(beTrue())
                        expect(mediaControl.controlsOverlayView.hidden).to(beTrue())
                        expect(mediaControl.controlsWrapperView.hidden).to(beTrue())
                    }
                    
                    it("Should show it's control after show is called") {
                        mediaControl.hide()
                        mediaControl.show()
                        
                        expect(mediaControl.playPauseButton.hidden).to(beFalse())
                        expect(mediaControl.controlsOverlayView.hidden).to(beFalse())
                        expect(mediaControl.controlsWrapperView.hidden).to(beFalse())
                    }
                }
            }
        }
    }
}