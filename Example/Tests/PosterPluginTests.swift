import Quick
import Nimble
import Clappr

class PosterPluginTests: QuickSpec {
    
    override func spec() {
        describe("Poster Plugin") {
            var container: Container!
            let sourceURL = NSURL(string: "http://globo.com/video.mp4")!
            let playback = Playback(url: sourceURL)
            let options = [posterUrl: "http://clappr.io/poster.png"]

            context("Initialization") {
                it("Should not be added if container has no options") {
                    container = Container(playback: playback)
                    
                    let posterPlugin = PosterPlugin()
                    container.addPlugin(posterPlugin)
                    
                    expect(posterPlugin.superview).to(beNil())
                }
                
                it("Should not be added if container doesn't have posterUrl Option") {
                    container = Container(playback: playback, options: ["anotherOption" : true])
                    
                    let posterPlugin = PosterPlugin()
                    container.addPlugin(posterPlugin)
                    
                    expect(posterPlugin.superview).to(beNil())
                }
                
                it("Should be added if container have posterUrl Option") {
                    container = Container(playback: playback, options: options)
                    
                    let posterPlugin = PosterPlugin()
                    container.addPlugin(posterPlugin)
                    
                    expect(posterPlugin.superview) == container
                }
            }
            
            context("State") {
                var posterPlugin: PosterPlugin!
                
                beforeEach() {
                    container = Container(playback: playback, options: options)
                    posterPlugin = PosterPlugin()
                    container.addPlugin(posterPlugin)
                }
                
                it("Should be hidden after container Play event ") {
                    expect(posterPlugin.hidden).to(beFalse())
                    container.trigger(ContainerEvent.Ready.rawValue)
                    expect(posterPlugin.hidden).to(beTrue())
                }
                
                it("Should be not hidden after container Ended event") {
                    container.trigger(ContainerEvent.Ready.rawValue)
                    container.trigger(ContainerEvent.Ended.rawValue)
                    
                    expect(posterPlugin.hidden).to(beFalse())
                }
                
            }
        }
    }
}