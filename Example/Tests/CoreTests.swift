import Quick
import Nimble
import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        let options = [kSourceUrl : "http//test.com"]
        var core: Core!
        let loader = Loader()
        loader.playbackPlugins = [StubPlayback.self]
        
        beforeEach() {
            core = Core(sources: [], loader: loader, options: options)
        }
        
        describe("Core") {
            context("Options") {
                it("Should have a constructor with options") {
                    let options = ["SomeOption" : true]
                    let core = Core(sources: [], loader: loader, options: options)
                    
                    expect(core.options["SomeOption"] as? Bool) == true
                }
            }
            
            context("Containers"){
                it("Should be created given a source") {
                    expect(core.containers).toNot(beEmpty())
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