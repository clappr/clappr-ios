import Quick
import Nimble
import Clappr

class ContainerFactoryTests: QuickSpec {
    
    override func spec() {
        let firstUrl = NSURL(string: "http://test.com")!
        let secondUrl = NSURL(string: "http://test2.com")!
        let invalidUrl = NSURL(string: "invalid")!
        var factory: ContainerFactory!
        var loader: Loader!
        let validSources = [firstUrl, secondUrl]
        
        beforeEach() {
            loader = Loader()
            loader.playbackPlugins = [StubPlayback.self]
        }
    
        context("Container creation") {
            it("Should create a container for each source") {
                factory = ContainerFactory(sources: validSources, loader: loader)
                
                expect(factory.createContainers().count) == validSources.count
            }
            
            it("Should not create container for url that cannot be played") {
                let invalidSources = [invalidUrl]
                factory = ContainerFactory(sources: invalidSources, loader: loader)
                
                expect(factory.createContainers()).to(beEmpty())
            }
            
            it("Should create container just for valid sources and ignore invalid") {
                let mixedSouces = [firstUrl, invalidUrl, secondUrl]
                factory = ContainerFactory(sources: mixedSouces, loader: loader)
                
                expect(factory.createContainers().count) == 2
            }
            
            it("Should add container plugins from loader") {
                loader.containerPlugins = [FakeContainerPlugin.self, AnotherFakeContainerPlugin.self]
                
                factory = ContainerFactory(sources: validSources, loader: loader)
                let containers = factory.createContainers()
                
                expect(containers[0].hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(containers[0].hasPlugin(AnotherFakeContainerPlugin)).to(beTrue())
                expect(containers[1].hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(containers[1].hasPlugin(AnotherFakeContainerPlugin)).to(beTrue())
            }
            
            it("Should add valid plugins only") {
                loader.containerPlugins = [InvalidContainerPlugin.self, FakeContainerPlugin.self]
                factory = ContainerFactory(sources: validSources, loader: loader)
                let containers = factory.createContainers()
                
                expect(containers[0].hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(containers[0].hasPlugin(InvalidContainerPlugin)).to(beFalse())
                expect(containers[1].hasPlugin(FakeContainerPlugin)).to(beTrue())
                expect(containers[1].hasPlugin(InvalidContainerPlugin)).to(beFalse())
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