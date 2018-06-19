import Quick
import Nimble
import AVFoundation

@testable import Clappr

class DVRPluginTests: QuickSpec {
    override func spec() {
        super.spec()

        describe(".DVRPlugin") {
            describe("#shouldEnableDVR") {
                it("returns true when live media supports DVR") {
                    let playback = AVFoundationPlayback(options: [:])
                    let container = Container()
                    container.playback = playback
                    
                    let dvrPlugin = DVRPlugin(context: container)
                    
                    let shouldEnableDVR = dvrPlugin.shouldEnableDVR()
                    
                    expect(shouldEnableDVR).to(beTrue())
                }
            }
        }
    }
}
