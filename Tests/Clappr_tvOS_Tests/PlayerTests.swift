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
                player = Player(options: options, externalPlugins: [AContainerPlugin.self])
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

            describe("attachTo") {
                it("triggers didAttachView") {
                    let player = Player(options: [:])

                    var didTriggerEvent = false
                    player.listenTo(player.core!, eventName: Event.didAttachView.rawValue) { _ in
                        didTriggerEvent = true
                    }

                    player.viewDidLoad()

                    expect(didTriggerEvent).to(beTrue())
                }
            }
            
            it("Should listen to didSelectSubtitle event") {
                var callbackWasCalled = false
                
                player.on(.didSelectSubtitle) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.didSelectSubtitle)
                expect(callbackWasCalled).to(beTrue())
            }
            
            it("Should listen to didSelectAudio event") {
                var callbackWasCalled = false
                
                player.on(.didSelectAudio) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.didSelectAudio)
                expect(callbackWasCalled).to(beTrue())
            }

            it("contains AVFoundationPlayback") {
                Loader.shared.resetPlugins()
                Loader.shared.resetPlaybacks()
                Player.hasAlreadyRegisteredPlaybacks = false
                _ = Player(options: options)

                expect(Loader.shared.playbacks.first).to(be(AVFoundationPlayback.self))
            }
        }
    }
    
    class StubPlayback: Playback {
        override class var name: String {
            return "StubPlayback"
        }
        
        override class func canPlay(_: Options) -> Bool {
            return true
        }
    }
    
    class SpecialStubPlayback: Playback {
        override class var name: String {
            return "SpecialStubPlayback"
        }
        
        override class func canPlay(_ options: Options) -> Bool {
            return options[kSourceUrl] as! String == PlayerTests.specialSource
        }
    }
}

class AContainerPlugin : ContainerPlugin {
    override class var name: String {
        return "AContainerPlugin"
    }
}
