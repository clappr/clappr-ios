import Quick
import Nimble
import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        let sources = [NSURL(string: "http//test.com")!, NSURL(string: "http//test2.com")!]
        var core: Core!
        let loader = Loader()
        loader.playbackPlugins = [StubPlayback.self]
        
        beforeEach() {
            core = Core(sources: sources, loader: loader)
        }
        
        describe("Core") {
            context("Sources") {
                it("Should store sources added on initialization") {
                    expect(core.sources[0]) == sources[0]
                    expect(core.sources[1]) == sources[1]
                }
            }
            
            context("Containers"){
                it("Should be created given an array of sources") {
                    expect(core.containers.count) == sources.count
                    expect(core.containers[0].playback.url) == sources[0]
                    expect(core.containers[1].playback.url) == sources[1]
                }
            }
            
            context("Media Control") {
                it("Should be created in top most container") {
                    expect(core.mediaControl).toNot(beNil())
                    expect(core.mediaControl.container) == core.containers.first
                }
            }
        }
    }
    
    class StubPlayback: Playback {
        override class func canPlay(url: NSURL) -> Bool {
            return true
        }
    }
}