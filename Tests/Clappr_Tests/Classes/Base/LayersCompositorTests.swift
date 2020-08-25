import Foundation
import Quick
import Nimble
@testable import Clappr

class LayersCompositorTests: QuickSpec {
    
    override func spec() {
        describe(".LayersCompositor") {
            context("When LayersCompositor composes its layers") {
                it("puts BackgroundLayer behind all other layers"){
                    let fakeLayer = FakeLayer()
                    let rootView = UIView()
                    rootView.addSubview(fakeLayer)
                    let layersCompositor = LayersCompositor()
                    
                    layersCompositor.compose(inside: rootView)
                    
                    expect(rootView.subviews.first).to(
                        beAKindOf(BackgroundLayer.self),
                        description: "BackgroundLayer should be the first subview of rootView."
                    )
                }
                it("puts PlaygroundLayer as the second layer"){
                    let rootView = UIView()
                    let layersCompositor = LayersCompositor()
                    
                    layersCompositor.compose(inside: rootView)
                    
                    expect(rootView.subviews[1]).to(
                        beAKindOf(PlaybackLayer.self),
                        description: "PlaybackLayer should be the first subview of rootView."
                    )
                }
            }
        }
    }
}

class FakeLayer: UIView {}
