import Quick
import Nimble
import Clappr

class ContainerFactoryTests: QuickSpec {
    
    override func spec() {
        let optionsWithValidSource = [kSourceUrl : "http://test.com"]
        let optionsWithInvalidSource = [kSourceUrl : "invalid"]
        var factory: ContainerFactory!
        var loader: Loader!
        
        beforeEach() {
            loader = Loader()
            loader.addExternalPlugins([StubPlayback.self])
        }
    
        context("Container creation") {
            it("Should create a container with valid playback for a valid source") {
                factory = ContainerFactory(loader: loader, options: optionsWithValidSource as Options)
                
                expect(factory.createContainer().playback.pluginName) == "AVPlayback"
            }
            
            it("Should create a container with invalid playback for url that cannot be played") {
                factory = ContainerFactory(loader: loader, options: optionsWithInvalidSource as Options)
                
                expect(factory.createContainer().playback.pluginName) == "NoOp"
            }
            
            it("Should add container plugins from loader") {
                loader.addExternalPlugins([FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])
                
                factory = ContainerFactory(loader: loader, options: optionsWithValidSource as Options)
                let container = factory.createContainer()
                
                expect(container.hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(container.hasPlugin(AnotherFakeContainerPlugin)).to(beTrue())
            }

            it("Should add a container context to all plugins") {
                factory = ContainerFactory(loader: loader, options: optionsWithValidSource as Options)
                let container = factory.createContainer()

                expect(container.plugins).toNot(beEmpty())
                for plugin in container.plugins {
                    expect(plugin.container) == container
                }
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
    
    class FakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "FakeContainerPlugin"
        }
    }
    
    class AnotherFakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "AnotherFakeContainerPlugin"
        }
    }
}
