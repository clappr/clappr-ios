import Quick
import Nimble
import Clappr

class PosterPluginTests: QuickSpec {
    
    override func spec() {
        describe("Poster Plugin") {
            var container: Container!
            let options = [kSourceUrl : "http://globo.com/video.mp4",
                           kPosterUrl : "http://clappr.io/poster.png"]
            let playback = StubPlayback(options: options as Options)
            

            context("Initialization") {
                it("Should not be rendered if container has no options") {
                    container = Container(playback: playback)
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.superview).to(beNil())
                }
                
                it("Should not be rendered if container doesn't have posterUrl Option") {
                    container = Container(playback: playback, options: ["anotherOption" : true])
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.superview).to(beNil())
                }
                
                it("Should be rendered if container have posterUrl Option") {
                    container = Container(playback: playback, options: options as Options)
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.superview) == container
                }
                
                it("Should be hidden if playback is a NoOp") {
                    container = Container(playback: NoOpPlayback(), options: options as Options)
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.isHidden) == true
                }
            }
            
            context("State") {
                var posterPlugin: PosterPlugin!
                
                beforeEach() {
                    container = Container(playback: playback, options: options as Options)
                    posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                }
                
                it("Should be hidden after container Play event ") {
                    expect(posterPlugin.isHidden).to(beFalse())
                    container.trigger(ContainerEvent.play.rawValue)
                    expect(posterPlugin.isHidden).to(beTrue())
                }
                
                it("Should be not hidden after container Ended event") {
                    container.trigger(ContainerEvent.play.rawValue)
                    container.trigger(ContainerEvent.ended.rawValue)
                    
                    expect(posterPlugin.isHidden).to(beFalse())
                }
                
            }
        }
    }
    
    class StubPlayback: Playback {
        override var pluginName: String {
            return "stupPlayback"
        }
    }
}
