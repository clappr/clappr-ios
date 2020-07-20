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
                    
                    if let backgroundLayer = rootView.subviews.first as? BackgroundLayer {
                        expect(backgroundLayer.bounds.size).to(equal(rootView.bounds.size))
                    } else {
                        fail("BackgroundLayer is not the first subview of rootView)")
                    }
                }
                
                it("adds BackgroundLayer behind all other layers"){
                    let fakeLayer = FakeLayer()
                    let rootView = UIView()
                    rootView.addSubview(fakeLayer)
                    
                    let _ = LayersCompositor(for: rootView)
                    
                    if let _ = rootView.subviews.first as? BackgroundLayer {
                        succeed()
                    } else {
                        fail("BackgroundLayer is not the first subview of rootView)")
                    }
                }
            }
        }
    }
}

class FakeLayer: UIView {}
