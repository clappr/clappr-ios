import Quick
import Nimble
import Clappr

class CoreFactoryTests: QuickSpec {
    
    override func spec() {
        describe("Core Factory") {
            context("Creation") {
                it("Should be able to create a core") {
                    let source = NSURL(string: "testUrl")!
                    let factory = CoreFactory(sources: [source])
                    let core = factory.create()
                    
                    expect(core).toNot(beNil())
                    expect(core.sources.first) == source
                }
                
                it("Should be able to create container with plugins") {
                    let loader = Loader()
                    loader.corePlugins = [FakeUICorePlugin.self]

                    let factory = CoreFactory(sources: [], loader: loader)
                    let core = factory.create()
                    
                    expect(core.hasPlugin(FakeUICorePlugin)).to(beTrue())
                }
            }
        }
    }
    
    class FakeUICorePlugin: UICorePlugin {}
}