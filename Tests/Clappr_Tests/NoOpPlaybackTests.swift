import Quick
import Nimble
import AVFoundation

@testable import Clappr

class NoOpPlaybackTests: QuickSpec {
    override func spec() {
        super.spec()

        describe(".NoOpPlayback") {
            describe("#render") {
                it("doesn't trigger ready event") {
                    let playback = NoOpPlayback(options: [:])
                    var didCallEvent = false
                    playback.on(Event.ready.rawValue) { _ in didCallEvent = true }

                    playback.render()

                    expect(didCallEvent).to(beFalse())
                }
            }

            describe("#stop") {
                it("triggers didStop event") {
                    let playback = NoOpPlayback(options: [:])
                    var didCallEvent = false
                    playback.on(Event.didStop.rawValue) { _ in didCallEvent = true }

                    playback.stop()

                    expect(didCallEvent).to(beTrue())
                }
            }
        }
    }
}
