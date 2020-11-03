import Quick
import Nimble
@testable import Clappr

class OverlayLayerTests: QuickSpec {
    override func spec() {
        describe(".OverlayLayerTests"){
            context("When overlay view is attached") {
                it("resizes to match the layer frame") {
                    let overlayView = UIView(frame: .zero)
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let layer = OverlayLayer(frame: frame)
                    let expectedSize = frame.size
                    let expectedCenter = layer.center
                    
                    layer.attachOverlay(overlayView)
                    
                    expect(overlayView.center).to(equal(expectedCenter))
                    expect(overlayView.frame.size).to(equal(expectedSize))
                }
                context("and the view size changes") {
                    it("resizes to match the view frame") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let overlayView = UIView(frame: .zero)
                        let layer = OverlayLayer(frame: smallFrame)
                        let expectedSize = bigFrame.size
                        
                        layer.attachOverlay(overlayView)
                        layer.frame = bigFrame
                        layer.layoutIfNeeded()
                        
                        expect(overlayView.frame.size).to(equal(expectedSize))
                    }
                }
            }
        }
    }
}
