import Quick
import Nimble
import Clappr

class CoreFactoryTests: QuickSpec {
    
    override func spec() {
        describe("Core Factory") {
            context("Creation") {
                it("Should be able to create a core") {
                    let source = NSURL(string: "testUrl")!
                    let core = CoreFactory.create([source])
                    
                    expect(core).toNot(beNil())
                    expect(core.sources.first) == source
                }
                
                it("Should be able to create container with plugins") {
                    let loader = Loader()
                    loader.corePlugins = [FakeUICorePlugin.self]

                    let core = CoreFactory.create([], loader: loader)
                    
                    expect(core.hasPlugin(FakeUICorePlugin)).to(beTrue())
                }
            }
        }
    }
    
    class FakeUICorePlugin: UICorePlugin {}
}