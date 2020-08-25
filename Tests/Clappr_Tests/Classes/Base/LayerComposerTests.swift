import Foundation
import Quick
import Nimble
@testable import Clappr

class LayerComposerTests: QuickSpec {
    
    override func spec() {
        describe(".LayerComposer") {
            context("When LayerComposer composes its layers") {
                it("puts BackgroundLayer as the first layer"){
                    let fakeLayer = FakeLayer()
                    let containerView = UIView()
                    let rootView = UIView()
                    rootView.addSubview(fakeLayer)
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView, adding: containerView)
                    
                    expect(rootView.subviews.first).to(
                        beAKindOf(BackgroundLayer.self),
                        description: "BackgroundLayer should be the first subview of rootView, got \(String(describing: type(of: rootView.subviews.first)))"
                    )
                }
                it("puts PlaygroundLayer as the second layer"){
                    let rootView = UIView()
                    let containerView = UIView()
                    let layerComposer = LayerComposer()
                    
                    layerComposer.compose(inside: rootView, adding: containerView)
                    
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
