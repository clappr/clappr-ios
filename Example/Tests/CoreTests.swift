import Quick
import Nimble
import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        let sources = [NSURL(string: "http//test.com")!, NSURL(string: "http//test2.com")!]
        
        describe("Core") {
            context("Initialization") {
                it("Should have a constructor tha receive an array of sources") {
                    let core = Core(sources: sources)
                    
                    expect(core.sources[0]) == sources[0]
                    expect(core.sources[1]) == sources[1]
                }
            }
        }
    }
}