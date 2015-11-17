import Quick
import Nimble
import Clappr

class MediaControlTests: QuickSpec {
    
    override func spec() {
        describe("MediaControl") {
            context("Initialization") {
                
                it("Should have a init method that receives a container") {
                    let url = NSURL(string: "http://globo.com/video.mp4")!
                    let container = Container(playback: Playback(url: url))
                    
                    let mediaControl = MediaControl.initWithContainer(container)
                    
                    expect(mediaControl).toNot(beNil())
                    expect(mediaControl.container) == container
                }
            }
        }
    }
}       