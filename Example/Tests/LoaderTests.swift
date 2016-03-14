import Quick
import Nimble
import Clappr

class LoaderTests: QuickSpec {
    
    override func spec() {
        context("Loader") {
            it("Should add external plugins to default plugins") {
                let loader = Loader()
                
                let nativePlaybackPluginsCount = loader.playbackPlugins.count
                let nativeContainerPluginsCount = loader.containerPlugins.count
                let nativeCorePluginsCount = loader.corePlugins.count
                
                loader.addExternalPlugins([StubPlayback.self, StubContainerPlugin.self, StubCorePlugin.self])
                
                expect(loader.playbackPlugins.count) == nativePlaybackPluginsCount + 1
                expect(loader.containerPlugins.count) == nativeContainerPluginsCount + 1
                expect(loader.corePlugins.count) == nativeCorePluginsCount + 1
            }
            
            it("Should give more priority for external plugin if names colide") {
                let loader = Loader()
                
                expect(loader.containerPlugins.filter({ $0.name == "spinner" }).count) == 1
                
                loader.addExternalPlugins([StubSpinnerPlugin.self])
                
                let spinnerPlugins = loader.containerPlugins.filter({ $0.name == "spinner" })
                let spinner = spinnerPlugins[0].init() as? StubSpinnerPlugin

                expect(spinnerPlugins.count) == 1
                expect(spinner).toNot(beNil())
            }
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