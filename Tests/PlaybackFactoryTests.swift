import Quick
import Nimble
import Clappr

class PlaybackFactoryTests: QuickSpec {

    override func spec() {
        let optionsWithValidSource = [kSourceUrl: "http://test.com"]
        let optionsWithInvalidSource = [kSourceUrl: "invalid"]
        var loader: Loader!

        beforeEach {
            loader = Loader()
            loader.addExternalPlugins([StubPlayback.self])
        }

        context("Playback creation") {
            it("Should create a valid playback for a valid source") {
                let factory = PlaybackFactory(loader: loader, options: optionsWithValidSource as Options)

                expect(factory.createPlayback().pluginName) == "AVPlayback"
            }

            it("Should create an invalid playback for url that cannot be played") {
                let factory = PlaybackFactory(loader: loader, options: optionsWithInvalidSource as Options)

                expect(factory.createPlayback().pluginName) == "NoOp"
            }
        }
    }

    class StubPlayback: Playback {
        override class func canPlay(_ options: Options) -> Bool {
            return options[kSourceUrl] as! String != "invalid"
        }

        override var pluginName: String {
            return "AVPlayback"
        }
    }
}
