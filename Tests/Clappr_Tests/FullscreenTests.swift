import Quick
import Nimble

@testable import Clappr

class FullscreenTests: QuickSpec {
    
    override func spec() {
        describe("#Fullscreen") {
            it("prefersHomeIndicatorAutoHidden is set as true") {
                let fullscreenController = FullscreenController()
                expect(fullscreenController.prefersHomeIndicatorAutoHidden()).to(beTrue())
            }
        }
    }
}
