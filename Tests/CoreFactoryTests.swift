import Quick
import Nimble
import Clappr

class CoreFactoryTests: QuickSpec {
    
    override func spec() {
        describe("Core Factory") {
            context("Creation") {
                it("Should be able to create a core") {
                    let options = [kSourceUrl : "testUrl"]
                    let core = CoreFactory.create(options: options as Options)
                    
                    expect(core).toNot(beNil())
                    expect(core.container).toNot(beNil())
                }
                
                it("Should be able to create container with plugins") {
                    let loader = Loader(externalPlugins: [FakeUICorePlugin.self])

                    let core = CoreFactory.create(loader)
                    
                    expect(core.hasPlugin(FakeUICorePlugin)).to(beTrue())
                }

                it("Should add a core context to all plugins") {
                    let loader = Loader(externalPlugins: [FakeUICorePlugin.self])
                    let core = CoreFactory.create(loader)

                    expect(core.plugins).toNot(beEmpty())
                    for plugin in core.plugins {
                        expect(plugin.core) == core
                    }
                }
            }
        }
    }
    
    class FakeUICorePlugin: UICorePlugin {
        override var pluginName: String {
            return "FakeCorePLugin"
        }
    }
}
