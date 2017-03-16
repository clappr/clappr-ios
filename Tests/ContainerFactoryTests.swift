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
