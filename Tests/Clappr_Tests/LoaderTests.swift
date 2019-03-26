import Quick
import Nimble

@testable import Clappr

class LoaderTests: QuickSpec {

    override func spec() {
        describe(".Loader") {

            beforeEach {
                Loader.shared.resetPlugins()
            }

            context("when adds external playbacks") {
                it("adds only playback to the correct array in Loader") {
                    let numberOfInitialPlaybacks = Loader.shared.playbacks.count
                    let numberOfContainerPlugins = Loader.shared.containerPlugins.count
                    let numberOfCorePlugins = Loader.shared.corePlugins.count

                    Loader.shared.register(playbacks: [StubPlayback.self])

                    expect(Loader.shared.playbacks.count).to(equal(numberOfInitialPlaybacks + 1))
                    expect(Loader.shared.containerPlugins.count).to(equal(numberOfContainerPlugins))
                    expect(Loader.shared.corePlugins.count).to(equal(numberOfCorePlugins))
                }
            }

            context("when adds container plugins") {
                it("adds only container to the correct array in Loader") {
                    let numberOfInitialPlaybacks = Loader.shared.playbacks.count
                    let numberOfContainerPlugins = Loader.shared.containerPlugins.count
                    let numberOfCorePlugins = Loader.shared.corePlugins.count

                    Loader.shared.register(plugins: [StubUIContainerPlugin.self])

                    expect(Loader.shared.playbacks.count).to(equal(numberOfInitialPlaybacks))
                    expect(Loader.shared.containerPlugins.count).to(equal(numberOfContainerPlugins + 1))
                    expect(Loader.shared.corePlugins.count).to(equal(numberOfCorePlugins))
                }
            }

            context("when adds core plugins") {
                it("adds only core to the correct array in Loader") {
                    let numberOfInitialPlaybacks = Loader.shared.playbacks.count
                    let numberOfContainerPlugins = Loader.shared.containerPlugins.count
                    let numberOfCorePlugins = Loader.shared.corePlugins.count

                    Loader.shared.register(plugins: [StubUICorePlugin.self])

                    expect(Loader.shared.playbacks.count).to(equal(numberOfInitialPlaybacks))
                    expect(Loader.shared.containerPlugins.count).to(equal(numberOfContainerPlugins))
                    expect(Loader.shared.corePlugins.count).to(equal(numberOfCorePlugins + 1))
                }
            }
            
            context("when adds both uiplugin and plugin") {
                it("loads both plugins") {
                    Loader.shared.register(plugins: [StubUICorePlugin.self, StubCorePlugin.self])
                    let plugins = Loader.shared.corePlugins
                    
                    expect(plugins.count).to(equal(2))
                }
            }

            context("when adds plugin with same name") {
                it("has one previous plugin with the same name") {
                    Loader.shared.register(plugins: [StubSpinnerPlugin.self])
                    let spinnerPlugins = Loader.shared.containerPlugins.filter({ $0.name == "spinner" })

                    expect(spinnerPlugins.count).to(equal(1))
                }

                it("gives priority to external plugin") {
                    Loader.shared.register(plugins: [StubSpinnerPlugin.self])
                    let spinnerPlugins = Loader.shared.containerPlugins.filter({ $0.name == "spinner" })

                    expect(spinnerPlugins.count).to(equal(1))
                    expect(String(describing: spinnerPlugins.first!)).to(equal("StubSpinnerPlugin"))
                }
            }
        }
    }

    class StubMediaControl: MediaControl {

    }

    class StubPlayback: Playback {
        override var pluginName: String {
            return "stupPlayback"
        }
    }

    class StubUIContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "uicontainer"
        }
    }

    class StubUICorePlugin: UICorePlugin {
        override var pluginName: String {
            return "uicore"
        }
    }

    class StubSpinnerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "spinner"
        }
    }
    
    class StubCorePlugin: CorePlugin {
        override var pluginName: String {
            return "core"
        }
    }
}
