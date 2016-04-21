import Quick
import Nimble
import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        let options = [kSourceUrl : "http//test.com"]
        var core: Core!
        let loader = Loader(externalPlugins: [StubPlayback.self])
        
        beforeEach() {
            core = Core(loader: loader, options: options)
        }
        
        describe("Core") {
            context("Options") {
                it("Should have a constructor with options") {
                    let options = ["SomeOption" : true]
                    let core = Core(loader: loader, options: options)
                    
                    expect(core.options["SomeOption"] as? Bool) == true
                }
            }
            
            context("Containers"){
                it("Should be created given a source") {
                    expect(core.container).toNot(beNil())
                }
            }
            
            context("Media Control") {
                it("Should have container reference") {
                    expect(core.mediaControl).toNot(beNil())
                    expect(core.mediaControl.container) == core.container
                }
                
                it("Should be the top view on core") {
                    core.render()
                    expect(core.subviews.last) == core.mediaControl
                }
            }
            
            describe("Plugins") {
                context("Addition") {
                    it("Should be able to add plugins") {
                        core.addPlugin(FakeCorePlugin())
                        expect(core.plugins.count) == 1
                    }
                    
                    it("Should add plugin as subview after rendered") {
                        let plugin = FakeCorePlugin()
                        core.addPlugin(plugin)
                        core.render()
                        
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
        override var pluginName: String {
            return "stupPlayback"
        }
    }
    
    class FakeCorePlugin: UICorePlugin {
        override var pluginName: String {
            return "FakeCorePLugin"
        }
    }
}