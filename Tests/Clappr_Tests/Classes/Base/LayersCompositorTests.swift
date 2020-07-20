import Foundation
import Quick
import Nimble
@testable import Clappr

class LayersCompositorTests: QuickSpec {
    
    override func spec() {
        describe(".LayersCompositor") {
            context("When LayersCompositor is attached to rootView") {
                it("adds BackgroundLayer behind all other layers"){
                    let fakeLayer = FakeLayer()
                    let rootView = UIView()
                    rootView.addSubview(fakeLayer)
                    
                    let _ = LayersCompositor(rootView: rootView)
                    
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

class FakeLayer: UIView, Layer {
    func attach(plugin: UIPlugin) {}
}
