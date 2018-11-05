import Quick
import Nimble
import AVFoundation

@testable import Clappr

class PlayerTests: QuickSpec {
    static let specialSource = "specialSource"
    
    override func spec() {
        describe("Player") {
            
            let options = [kSourceUrl: "http://clappr.com/video.mp4"]
            
            var player: Player!
            var playback: Playback!
            
            beforeEach {
                Loader.shared.resetPlugins()
                player = Player(options: options, externalPlugins: [SpecialStubPlayback.self, StubPlayback.self])
                playback = player.activePlayback
            }
            
            it("Should load source on core when initializing") {
                let player = Player(options: options as Options)
                
                if let core = player.core {
                    expect(core.activeContainer).toNot(beNil())
                } else {
                    fail("player.core is nil")
                }
            }
            
            it("Should listen to playing event") {
                var callbackWasCalled = false
                
                player.on(.playing) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.playing)
                expect(callbackWasCalled).to(beTrue())
            }

            describe("configure") {
                it("changes Core options") {
                    player.configure(options: ["foo": "bar"])
                    
                    expect(player.core!.options["foo"] as? String).to(equal("bar"))
                }
            }
            
            it("Should listen to subtitleSelected event") {
                var callbackWasCalled = false
                
                player.on(.subtitleSelected) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.subtitleSelected)
                expect(callbackWasCalled).to(beTrue())
            }
            
            it("Should listen to audioSelected event") {
                var callbackWasCalled = false
                
                player.on(.audioSelected) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.audioSelected)
                expect(callbackWasCalled).to(beTrue())
            }

            it("contains AVFoundationPlayback") {
                Loader.shared.resetPlugins()
                Player.hasAlreadyRegisteredPlugins = false
                _ = Player(options: options)

                expect(Loader.shared.playbacks.first).to(be(AVFoundationPlayback.self))
            }
        }
    }
    
    class StubPlayback: Playback {
        override var pluginName: String {
            return "StubPlayback"
        }
        
        override class func canPlay(_: Options) -> Bool {
            return true
        }
    }
    
    class SpecialStubPlayback: Playback {
        override var pluginName: String {
            return "SpecialStubPlayback"
        }
        
        override class func canPlay(_ options: Options) -> Bool {
            return options[kSourceUrl] as! String == PlayerTests.specialSource
        }
    }
}
