import Quick
import Nimble
@testable import Clappr

class PlaybackFactoryTests: QuickSpec {

    override func spec() {
        let optionsWithValidSource = [kSourceUrl: "http://test.com"]
        let optionsWithInvalidSource = [kSourceUrl: "invalid"]

        beforeEach {
            Loader.shared.resetPlugins()
            Loader.shared.register(playbacks: [StubPlayback.self])
        }

        context("Playback creation") {
            it("Should create a valid playback for a valid source") {
                let factory = PlaybackFactory(options: optionsWithValidSource as Options)

                expect(factory.createPlayback().pluginName) == "AVPlayback"
            }

            it("Should create an invalid playback for url that cannot be played") {
                let factory = PlaybackFactory(options: optionsWithInvalidSource as Options)

                expect(factory.createPlayback().pluginName) == "NoOp"
            }
        }
    }

    class StubPlayback: Playback {
        override class func canPlay(_ options: Options) -> Bool {
            return options[kSourceUrl] as! String != "invalid"
        }

        override class var name: String {
            return "AVPlayback"
        }
    }
}
