import Quick
import Nimble
import Clappr

class ContainerFactoryTests: QuickSpec {
    
    override func spec() {
        let firstUrl = NSURL(string: "http://test.com")!
        let secondUrl = NSURL(string: "http://test2.com")!
        let invalidUrl = NSURL(string: "invalid")!
        var factory: ContainerFactory!
        let loader = Loader()
        loader.playbackPlugins.append(StubPlayback)
    
        context("Container creation") {
            it("Should create a container for each source") {
                let sources = [firstUrl, secondUrl]
                factory = ContainerFactory(sources: sources, loader: loader)
                
                expect(factory.createContainers().count) == sources.count
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
        }
    }
    
    class StubPlayback: Playback {
        override class func canPlay(url: NSURL) -> Bool {
            return url.absoluteString != "invalid"
        }
    }
}