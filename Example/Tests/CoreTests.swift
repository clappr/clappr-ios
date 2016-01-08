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
            context("Options") {
                it("Should have a constructor with options") {
                    let options = ["SomeOption" : true]
                    let core = Core(sources: sources, loader: loader, options: options)
                    
                    expect(core.options["SomeOption"] as? Bool) == true
                }
            }
            
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
            
            describe("Plugins") {
                context("Addition") {
                    it("Should be able to add plugins") {
                        core.addPlugin(FakeCorePlugin())
                        expect(core.plugins.count) == 1
                    }
                    
                    it("Should add plugin as subview") {
                        let plugin = FakeCorePlugin()
                        core.addPlugin(plugin)
                        
                        expect(plugin.superview) == core
                    }
                }
                
                context("Verification") {
                    it("Should return true if a plugin is installed") {
                        core.addPlugin(FakeCorePlugin())
                        let containsPlugin = core.hasPlugin(FakeCorePlugin)
                        expect(containsPlugin).to(beTrue())
                    }
                    
                    it("Should return false if a plugin isn't installed") {
                        core.addPlugin(UICorePlugin())
                        let containsPlugin = core.hasPlugin(FakeCorePlugin)
                        expect(containsPlugin).to(beFalse())
                    }
                }
            }
        }
    }
    
    class StubPlayback: Playback {
        override class func canPlay(url: NSURL) -> Bool {
            return true
        }
    }
    
    class FakeCorePlugin: UICorePlugin {}
}