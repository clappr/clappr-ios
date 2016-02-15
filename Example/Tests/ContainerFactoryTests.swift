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
            loader.playbackPlugins = [StubPlayback.self]
        }
    
        context("Container creation") {
            it("Should create a container for a valid source") {
                factory = ContainerFactory(loader: loader, options: optionsWithValidSource)
                
                expect(factory.createContainer()).toNot(beNil())
            }
            
            it("Should not create container for url that cannot be played") {
                factory = ContainerFactory(loader: loader, options: optionsWithInvalidSource)
                
                expect(factory.createContainer()).to(beNil())
            }
            
            it("Should add container plugins from loader") {
                loader.containerPlugins = [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self]
                
                factory = ContainerFactory(loader: loader, options: optionsWithValidSource)
                let container = factory.createContainer()!
                
                expect(container.hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(container.hasPlugin(AnotherFakeContainerPlugin)).to(beTrue())
            }
            
            it("Should add valid plugins only") {
                loader.containerPlugins = [InvalidContainerPlugin.self, FakeContainerPlugin.self]
                factory = ContainerFactory(loader: loader, options: optionsWithValidSource)
                let container = factory.createContainer()!
                
                expect(container.hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(container.hasPlugin(InvalidContainerPlugin)).to(beFalse())
            }
        }
    }
    
    class StubPlayback: Playback {
        override class func canPlay(url: NSURL) -> Bool {
            return url.absoluteString != "invalid"
        }
    }
    
    class FakeContainerPlugin: UIContainerPlugin {}
    class AnotherFakeContainerPlugin: UIContainerPlugin {}
    class InvalidContainerPlugin: NSObject {}
}