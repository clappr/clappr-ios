import Foundation
import Quick
import Nimble
@testable import Clappr

class LayersCompositorTests: QuickSpec {
    
    override func spec() {
        describe(".LayersCompositor") {
            context("When LayersCompositor is attached to rootView") {
                it("creates BackgroundLayer with the same size as rootView") {
                    let frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                    let rootView = UIView(frame: frame)
                    
                    let _ = LayersCompositor(for: rootView)
                    
                    expect(rootView.subviews.first).to(beAKindOf(BackgroundLayer.self))
                    expect(rootView.subviews.first?.bounds.size).to(equal(rootView.bounds.size))
                }
                
                it("adds BackgroundLayer behind all other layers"){
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
