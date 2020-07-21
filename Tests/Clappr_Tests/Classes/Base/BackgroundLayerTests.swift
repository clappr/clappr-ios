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
            context("When BackgroundLayer is attached to a view") {
                it("resizes to fill the view bounds") {
                    let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                    let rootView = UIView(frame: frame)
                    let backgroundLayer = BackgroundLayer()
                    
                    backgroundLayer.attach(to: rootView)
                    backgroundLayer.layoutIfNeeded()
                    
                    expect(backgroundLayer.bounds.size).to(equal(rootView.bounds.size))
                }
            }
        }
    }
}
