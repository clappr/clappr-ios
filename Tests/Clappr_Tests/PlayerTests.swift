import Quick
import Nimble
@testable import Clappr

class PlayerTests: QuickSpec {
    static let specialSource = "specialSource"

    override func spec() {
        describe("Player") {

            let options = [kSourceUrl: "http://clappr.com/video.mp4"]

            var player: Player!
            var playback: StubPlayback!

            beforeEach {
                player = Player(options: options, externalPlugins: [SpecialStubPlayback.self, StubPlayback.self])
                playback = player.activePlayback as! StubPlayback
            }

            it("Should load source on core when initializing") {
                let player = Player(options: options as Options)

                if let core = player.core {
                    expect(core.activeContainer).toNot(beNil())
                } else {
                    fail("player.core is nil")
                }
            }

            it("Should listen to playing event") {
                var callbackWasCalled = false

                player.on(.playing) { _ in
                    callbackWasCalled = true
                }

                playback.trigger(.playing)
                expect(callbackWasCalled).to(beTrue())
            }

            it("Should route events after new playback is created") {
                var callbackWasCalled = false

                player.on(.playing) { _ in
                    callbackWasCalled = true
                }

                expect(player.activePlayback is StubPlayback).to(beTrue())
                player.load(PlayerTests.specialSource)
                expect(player.activePlayback is SpecialStubPlayback).to(beTrue())

                player.activePlayback?.trigger(.playing)
                expect(callbackWasCalled).to(beTrue())
            }

            it("loads LoadingCorePlugin") {
                let player = Player()

                let containsPlugin = player.core?.plugins.filter { $0 is LoadingCorePlugin }.count
                expect(containsPlugin).to(equal(1))
            }
        }
    }

    class StubPlayback: Playback {
        override var pluginName: String {
            return "StubPlayback"
        }

        override class func canPlay(_: Options) -> Bool {
            return true
        }
    }

    class SpecialStubPlayback: Playback {
        override var pluginName: String {
            return "SpecialStubPlayback"
        }

        override class func canPlay(_ options: Options) -> Bool {
            return options[kSourceUrl] as! String == PlayerTests.specialSource
        }
    }
}
