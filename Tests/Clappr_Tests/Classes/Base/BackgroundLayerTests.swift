import Foundation
import Quick
import Nimble
@testable import Clappr

class BackgroundLayerTests: QuickSpec {
    
    override func spec() {
        describe(".BackgroundLayer") {
            context("When BackgroundLayer is created") {
                it("has a black background"){
                    let layer = BackgroundLayer()
                    
                    expect(layer.backgroundColor).to(equal(UIColor.black))
                }
            }
        }
    }
}
