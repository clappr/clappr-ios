import Quick
import Nimble
@testable import Clappr

class LoaderTests: QuickSpec {

    override func spec() {
        context("Loader") {
            it("adds external plugins to default plugins") {

                Loader.shared.resetPlugins()
                let playbacksCount = Loader.shared.playbacks.count
                let containerPluginsCount = Loader.shared.containerPlugins.count
                let corePluginsCount = Loader.shared.corePlugins.count

                Loader.shared.addExternalPlugins([StubPlayback.self, StubContainerPlugin.self, StubCorePlugin.self])

                expect(Loader.shared.playbacks.count) == playbacksCount + 1
                expect(Loader.shared.containerPlugins.count) == containerPluginsCount + 1
                expect(Loader.shared.corePlugins.count) == corePluginsCount + 1
            }

            it("gives more priority for external plugin if names colide") {

                expect(Loader.shared.containerPlugins.filter({ $0.name == "spinner" }).count) == 1

                Loader.shared.addExternalPlugins([StubSpinnerPlugin.self])

                let spinnerPlugins = Loader.shared.containerPlugins.filter({ $0.name == "spinner" })
                let spinner = spinnerPlugins[0].init() as? StubSpinnerPlugin

                expect(spinnerPlugins.count) == 1
                expect(spinner).toNot(beNil())
            }
        }
    }

    class StubMediaControl: MediaControl {

        override class func loadNib() -> UINib? {
            let nib = UINib()
            nib.accessibilityHint = "StubMediaControl"
            return nib
        }
    }

    class StubPlayback: Playback {
        override var pluginName: String {
            return "stupPlayback"
        }
    }

    class StubContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "container"
        }
    }

    class StubCorePlugin: UICorePlugin {
        override var pluginName: String {
            return "core"
        }
    }

    class StubSpinnerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "spinner"
        }
    }
}
