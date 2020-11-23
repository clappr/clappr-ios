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
                it("adds MediaControlLayer as the third layer"){
                    let index = 2
                    let rootView = UIView()
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView)
                    
                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(MediaControlLayer.self),
                        description: "MediaControlLayer should be the third subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
                it("adds CoreLayer as the fourth layer"){
                    let index = 3
                    let rootView = UIView()
                    let layerComposer = LayerComposer()

                    layerComposer.compose(inside: rootView)

                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(CoreLayer.self),
                        description: "CoreLayer should be the fourth subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
                it("adds OverlayLayer as the fifth layer"){
                    let index = 4
                    let rootView = UIView()
                    let layerComposer = LayerComposer()

                    layerComposer.compose(inside: rootView)

                    let layer = getLayer(from: rootView, at: index)
                    expect(layer).to(
                        beAKindOf(OverlayLayer.self),
                        description: "OverlayLayer should be the fifth subview of rootView, got \(String(describing: type(of: layer)))"
                    )
                }
            }
        }
        
        context("When LayerComposer changes its layers visibility") {
            it("show all visual layers") {
                let rootView = UIView()
                let layerComposer = LayerComposer()
                layerComposer.compose(inside: rootView)

                layerComposer.showViews()

                let containerLayer = getLayer(from: rootView, at: 2)
                let mediaControlLayer = getLayer(from: rootView, at: 3)
                let coreLayer = getLayer(from: rootView, at: 4)
                let overlayLayer = getLayer(from: rootView, at: 5)

                expect(containerLayer?.isHidden).to(beFalse())
                expect(mediaControlLayer?.isHidden).to(beFalse())
                expect(coreLayer?.isHidden).to(beFalse())
                expect(overlayLayer?.isHidden).to(beFalse())

            }

            it("hides all visual layers") {
                let rootView = UIView()
                let layerComposer = LayerComposer()
                layerComposer.compose(inside: rootView)

                layerComposer.hideViews()

                let containerLayer = getLayer(from: rootView, at: 2)
                let mediaControlLayer = getLayer(from: rootView, at: 3)
                let coreLayer = getLayer(from: rootView, at: 4)
                let overlayLayer = getLayer(from: rootView, at: 5)

                expect(containerLayer?.isHidden).to(beTrue())
                expect(mediaControlLayer?.isHidden).to(beTrue())
                expect(coreLayer?.isHidden).to(beTrue())
                expect(overlayLayer?.isHidden).to(beTrue())

            }
        }
        
        func getLayer(from rootView: UIView, at index: Int) -> Layer? {
            return rootView.subviews[index] as? Layer
        }
    }
    
    class FakeLayer: UIView {}
}
