import Quick
import Nimble
@testable import Clappr

class MediaControlLayerTests: QuickSpec {
    override func spec() {
        describe(".MediaControlLayer") {
            context("When a MediaControl is attached") {
                it("resizes to match the layer bounds") {
                    let mediaControlView = UIView(frame: .zero)
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let layer = MediaControlLayer(frame: frame)

                    layer.attachMediaControl(mediaControlView)
                    layer.layoutIfNeeded()

                    expect(mediaControlView.center).to(equal(layer.center))
                    expect(mediaControlView.bounds.size).to(equal(layer.bounds.size))

                }
                context("and the view size changes") {
                    it("resizes to match the view bounds") {
                        let smallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
                        let bigFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
                        let mediaControlView = UIView(frame: .zero)
                        let mediaControlLayer = MediaControlLayer(frame: smallFrame)

                        mediaControlLayer.attachMediaControl(mediaControlView)
                        mediaControlLayer.layoutIfNeeded()
                        mediaControlLayer.bounds = bigFrame
                        mediaControlLayer.layoutIfNeeded()

                        expect(mediaControlView.bounds.size).to(equal(bigFrame.size))
                    }
                }
            }
        }
    }
}
