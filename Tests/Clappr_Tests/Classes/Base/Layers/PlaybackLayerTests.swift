import Quick
import Nimble
@testable import Clappr

class PlaybackLayerTests: QuickSpec {
    override func spec() {
        describe(".PlaybackLayer") {
            context("When a view is attached") {
                it("resizes to match the layer frame") {
                    let view = UIView(frame: .zero)
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let layer = PlaybackLayer(frame: frame)
                    
                    layer.attach(view)
                    
                    expect(view.center).to(equal(layer.center))
                    expect(view.frame.size).to(equal(layer.frame.size))
                    
                }
                context("and the view size changes") {
                    it("resizes to match the view frame") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let view = UIView(frame: .zero)
                        let playbackLayer = PlaybackLayer(frame: smallFrame)
                        
                        playbackLayer.attach(view)
                        playbackLayer.frame = bigFrame
                        playbackLayer.layoutIfNeeded()
                        
                        expect(view.frame.size).to(equal(bigFrame.size))
                    }
                }
            }
        }
    }
}
