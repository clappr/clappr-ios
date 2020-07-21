import Foundation
import Quick
import Nimble
@testable import Clappr

class LayersCompositorTests: QuickSpec {
    
    override func spec() {
        describe(".LayersCompositor") {
            context("When LayersCompositor is attached to rootView") {
                it("puts BackgroundLayer behind all other layers"){
                    let fakeLayer = FakeLayer()
                    let rootView = UIView()
                    rootView.addSubview(fakeLayer)
                    
                    let _ = LayersCompositor(for: rootView)
                    
                    expect(rootView.subviews.first).to(
                        beAKindOf(BackgroundLayer.self),
                        description: "BackgroundLayer should be the first subview of rootView."
                    )
                }
            }
        }
    }
}

class FakeLayer: UIView {}
