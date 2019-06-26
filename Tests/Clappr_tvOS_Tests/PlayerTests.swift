import Quick
import Nimble
import AVFoundation
import AVKit

@testable import Clappr

class PlayerTests: QuickSpec {
    static let specialSource = "specialSource"
    
    override func spec() {
        describe("Player") {
            let options: Options = [kSourceUrl: "http://clappr.com/video.mp4"]
            var player: Player!
            var playback: Playback!
            
            beforeEach {
                Loader.shared.resetPlugins()
                player = Player(options: options, externalPlugins: [AContainerPlugin.self])
                playback = player.activePlayback
            }

            it("is an instance of AVPlayerViewController") {
                expect(player).to(beAKindOf(AVPlayerViewController.self))
            }
            
            it("loads source on core when initializing") {
                let player = Player(options: options)
                
                if let core = player.core {
                    expect(core.activeContainer).toNot(beNil())
                } else {
                    fail("player.core is nil")
                }
            }
            
            it("listen to playing event") {
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
            
            it("listen to didSelectSubtitle event") {
                var callbackWasCalled = false
                
                player.on(.didSelectSubtitle) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.didSelectSubtitle)
                expect(callbackWasCalled).to(beTrue())
            }
            
            it("listen to didSelectAudio event") {
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

            it("contains focusable items") {
                let button = UIButton(type: .system)
                button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                player.contentOverlayView?.addSubview(button)
                expect(player.focusEnvironments).to(equal([button]))
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
