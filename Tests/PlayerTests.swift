import Quick
import Nimble
import Clappr

class PlayerTests: QuickSpec {
    override func spec() {
        describe("Player") {
            
            let options = [kSourceUrl : "http://someUrl.com"]
            
            it("Should load source on core when initializing") {
                let player = Player(options: options)
                
                expect(player.core.container).toNot(beNil())
            }
        }
    }
}