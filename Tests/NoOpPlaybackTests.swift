import Quick
import Nimble
import AVFoundation

@testable import Clappr

class NoOpPlaybackTests: QuickSpec {
    override func spec() {
        super.spec()

        describe(".NoOpPlayback") {
            describe("#render") {
                it("not trigger ready event") {
                    let playback = NoOpPlayback()
                    var didCallEvent = false
                    playback.on(Event.ready.rawValue) { _ in
                        didCallEvent = true
                    }

                    playback.render()

                    expect(didCallEvent) == false
                }
            }
        }
    }
}
