import Quick
import Nimble
import Clappr

class UIPluginTests: QuickSpec {
    
    override func spec() {
        describe("Instantiation") {
            
            it("Should enable plugin by default") {
                let plugin = UIPlugin()
                expect(plugin.enabled).to(beTrue())
            }
        }
        
    }
}