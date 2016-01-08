import Quick
import Nimble
import Clappr

class PlayerTests: QuickSpec {
    override func spec() {
        describe("Player") {
            let firstUrl = NSURL(string: "http://someUrl.com")!
            let secondUrl = NSURL(string: "http://anotherUrl.com")!
            
            it("Should load source on core when initializing") {
                let player = Player(source: firstUrl)
                
                expect(player.core.sources.count) == 1
                expect(player.core.sources[0]) == firstUrl
            }
            
            it("Should load sources array on core when initializing") {
                let player = Player(sources: [firstUrl, secondUrl])
                
                expect(player.core.sources.count) == 2
                expect(player.core.sources[0]) == firstUrl
                expect(player.core.sources[1]) == secondUrl
            }
        }
    }
}