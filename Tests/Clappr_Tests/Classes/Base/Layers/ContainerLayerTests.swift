import Quick
import Nimble
@testable import Clappr

class ContainerLayerTests: QuickSpec {
    override func spec() {
        describe(".ContainerLayer") {
            context("When a Container is attached") {
                it("resizes to match the layer bounds") {
                    let containerView = UIView(frame: .zero)
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let layer = ContainerLayer(frame: frame)
                    
                    layer.attachContainer(containerView)
                    layer.layoutIfNeeded()
                    
                    expect(containerView.center).to(equal(layer.center))
                    expect(containerView.bounds.size).to(equal(layer.bounds.size))
                    
                }
                context("and the view size changes") {
                    it("resizes to match the view bounds") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let containerView = UIView(frame: .zero)
                        let containerLayer = ContainerLayer(frame: smallFrame)
                        
                        containerLayer.attachContainer(containerView)
                        containerLayer.layoutIfNeeded()
                        containerLayer.bounds = bigFrame
                        containerLayer.layoutIfNeeded()
                        
                        expect(containerView.bounds.size).to(equal(bigFrame.size))
                    }
                }
            }
        }
    }
}
