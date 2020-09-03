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
                    let expectedSize = frame.size
                    let expectedCenter = layer.center
                    
                    layer.attachContainer(containerView)
                    layer.layoutIfNeeded()
                    
                    expect(containerView.center).to(equal(expectedCenter))
                    expect(containerView.bounds.size).to(equal(expectedSize))
                    
                }
                context("and the view size changes") {
                    it("resizes to match the view bounds") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let containerView = UIView(frame: .zero)
                        let containerLayer = ContainerLayer(frame: smallFrame)
                        let expectedSize = bigFrame.size
                        
                        containerLayer.attachContainer(containerView)
                        containerLayer.layoutIfNeeded()
                        containerLayer.bounds = bigFrame
                        containerLayer.layoutIfNeeded()
                        
                        expect(containerView.bounds.size).to(equal(expectedSize))
                    }
                }
            }
        }
    }
}
