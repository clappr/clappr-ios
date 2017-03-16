import Quick
import Nimble
import Clappr

class PosterPluginTests: QuickSpec {
    
    override func spec() {
        describe("Poster Plugin") {
            var container: Container!
            let options = [kSourceUrl : "http://globo.com/video.mp4",
                           kPosterUrl : "http://clappr.io/poster.png"]

            context("Initialization") {
                it("Should not be rendered if container has no options") {
                    container = Container()
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.superview).to(beNil())
                }
                
                it("Should not be rendered if container doesn't have posterUrl Option") {
                    container = Container(options: ["anotherOption" : true])
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.superview).to(beNil())
                }
                
                it("Should be rendered if container have posterUrl Option") {
                    container = Container(options: options)

                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.superview) == container
                }
                
                it("Should be hidden if playback is a NoOp") {
                    container = Container(options: [kSourceUrl : "none", kPosterUrl: "http://clappr.io/poster.png"])
                    
                    let posterPlugin = PosterPlugin(context: container)
                    container.addPlugin(posterPlugin)
                    container.render()
                    
                    expect(posterPlugin.isHidden) == true
                }
            }
            
            context("State") {
                var posterPlugin: PosterPlugin!
                
                beforeEach() {
                    container = Container(options: options)
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
