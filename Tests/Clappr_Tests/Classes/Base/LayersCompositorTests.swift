import Foundation
import Quick
import Nimble
@testable import Clappr

class LayersCompositorTests: QuickSpec {
    
    override func spec() {
        describe(".LayersCompositor") {
            context("When LayersCompositor composes its layers") {
                it("puts BackgroundLayer as the first layer"){
                    let fakeLayer = FakeLayer()
                    let rootView = UIView()
                    rootView.addSubview(fakeLayer)
                    let layersCompositor = LayersCompositor()
                    
                    layersCompositor.compose(inside: rootView)
                    
                    expect(rootView.subviews.first).to(
                        beAKindOf(BackgroundLayer.self),
                        description: "BackgroundLayer should be the first subview of rootView, got \(String(describing: type(of: rootView.subviews.first)))"
                    )
                }
                it("puts PlaygroundLayer as the second layer"){
                    let rootView = UIView()
                    let layersCompositor = LayersCompositor()
                    
                    layersCompositor.compose(inside: rootView)
                    
                    expect(rootView.subviews[1]).to(
                        beAKindOf(PlaybackLayer.self),
                        description: "PlaybackLayer should be the first subview of rootView, got \(String(describing: type(of: rootView.subviews[0])))"
                    )
                }
            }
        }
    }
}

class FakeLayer: UIView {}
