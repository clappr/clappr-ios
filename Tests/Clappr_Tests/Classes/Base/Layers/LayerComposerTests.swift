import Foundation
import Quick
import Nimble
@testable import Clappr

class LayerComposerTests: QuickSpec {
    
    override func spec() {
        describe(".LayerComposer") {
            context("When LayerComposer composes its layers") {
                it("adds BackgroundLayer as the first layer"){
                    let index = 0
                    let fakeLayer = FakeLayer()
                    let rootView = UIView()
                    rootView.insertSubview(fakeLayer, at: 0)
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView)
                    
                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(BackgroundLayer.self),
                        description: "BackgroundLayer should be the first subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
                it("adds PlaygroundLayer as the second layer"){
                    let index = 1
                    let rootView = UIView()
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView)
                    
                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(PlaybackLayer.self),
                        description: "PlaybackLayer should be the second subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
                it("adds ContainerLayer as the third layer"){
                    let index = 2
                    let rootView = UIView()
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView)
                    
                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(ContainerLayer.self),
                        description: "ContainerLayer should be the third subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
                it("adds MediaControlLayer as the fourth layer"){
                    let index = 3
                    let rootView = UIView()
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView)
                    
                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(MediaControlLayer.self),
                        description: "MediaControlLayer should be the fourth subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
            }
        }
        
        func getLayer(from rootView: UIView, at index: Int) -> Layer? {
            return rootView.subviews[index] as? Layer
        }
    }
    
    class FakeLayer: UIView {}
}
