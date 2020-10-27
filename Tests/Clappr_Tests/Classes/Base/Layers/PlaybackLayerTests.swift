import Quick
import Nimble
@testable import Clappr

class PlaybackLayerTests: QuickSpec {
    override func spec() {
        describe(".PlaybackLayer") {
            context("When a Playback is attached") {
                it("resizes to match the layer frame") {
                    let playbackView = UIView(frame: .zero)
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let layer = PlaybackLayer(frame: frame)
                    
                    layer.attachPlayback(playbackView)
                    
                    expect(playbackView.center).to(equal(layer.center))
                    expect(playbackView.frame.size).to(equal(layer.frame.size))
                    
                }
                context("and the view size changes") {
                    it("resizes to match the view frame") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let playbackView = UIView(frame: .zero)
                        let playbackLayer = PlaybackLayer(frame: smallFrame)
                        
                        playbackLayer.attachPlayback(playbackView)
                        playbackLayer.frame = bigFrame
                        playbackLayer.layoutIfNeeded()
                        
                        expect(playbackView.frame.size).to(equal(bigFrame.size))
                    }
                }
            }
        }
    }
}
