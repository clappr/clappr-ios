import Quick
import Nimble
import Clappr

class UICorePluginTests: QuickSpec {
    
    override func spec() {
        describe("Initialization") {
            let core = Core(sources: [])
            
            it("Should have a initializer that receives a core instance") {
                let plugin = UICorePlugin(core: core)
                expect(plugin.core) == core
            }
            
            it("Should have it's view as a child of core view") {
                let plugin = UICorePlugin(core: core)
                expect(plugin.superview) == core
            }
        }
    }
}