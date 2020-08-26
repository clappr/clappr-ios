import Quick
import Nimble
@testable import Clappr

class PlaybackLayerTests: QuickSpec {
    override func spec() {
        describe(".PlaybackLayer") {
            context("When a Playback is attached") {
                it("resizes to match the layer bounds") {
                    let playbackView = UIView(frame: .zero)
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let layer = PlaybackLayer(frame: frame)
                    
                    layer.attachPlayback(playbackView)
                    layer.layoutIfNeeded()
                    
                    expect(playbackView.center).to(equal(layer.center))
                    expect(playbackView.bounds.size).to(equal(layer.bounds.size))
                    
                }
                context("and the view size changes") {
                    it("resizes to match the view bounds") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let playbackView = UIView(frame: .zero)
                        let playbackLayer = PlaybackLayer(frame: smallFrame)
                        
                        playbackLayer.attachPlayback(playbackView)
                        playbackLayer.layoutIfNeeded()
                        playbackLayer.bounds = bigFrame
                        playbackLayer.layoutIfNeeded()
                        
                        expect(playbackView.bounds.size).to(equal(bigFrame.size))
                    }
                }
            }
        }
    }
}
