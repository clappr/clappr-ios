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
                player = Player(options: options, externalPlugins: [AContainerPlugin.self, AnUICorePlugin.self])
                playback = player.activePlayback
            }

            it("is an instance of AVPlayerViewController") {
                expect(player).to(beAKindOf(AVPlayerViewController.self))
            }

            describe("#init") {
                it("loads source on core when initializing") {
                    expect(player.core?.activeContainer).toNot(beNil())
                }
            }
            
            it("listens to playing event") {
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

                context("when source is passed in configure") {
                    it("triggers willLoadSource in core") {
                        var triggeredWillLoadSource = false
                        player.core!.on(Event.willLoadSource.rawValue) { userInfo in
                            triggeredWillLoadSource = true
                        }

                        player.configure(options: [kSourceUrl: "new source url"])

                        expect(triggeredWillLoadSource).to(beTrue())
                    }
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
            
            it("listens to didSelectSubtitle event") {
                var callbackWasCalled = false
                
                player.on(.didSelectSubtitle) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.didSelectSubtitle)
                expect(callbackWasCalled).to(beTrue())
            }
            
            it("listens to didSelectAudio event") {
                var callbackWasCalled = false
                
                player.on(.didSelectAudio) { _ in
                    callbackWasCalled = true
                }
                
                playback.trigger(.didSelectAudio)
                expect(callbackWasCalled).to(beTrue())
            }
            
            it("listens to didUpateBitrate event") {
                var callbackWasCalled = false
                
                player.on(.didUpdateBitrate) { _ in
                    callbackWasCalled = true
                }
                playback.trigger(.didUpdateBitrate)
                
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
                let player = Player(options: [kMediaControl: true], externalPlugins: [AnUICorePlugin.self])

                player.viewDidLoad()

                expect(player.focusEnvironments.contains(where: { $0 is UIButton} )).to(beTrue())
            }

            it("triggers willLoadSource in core on load") {
                Loader.shared.resetPlaybacks()
                Player.register(playbacks: [SpecialStubPlayback.self])
                let player = Player(options: options)
                var willLoadSourceTriggered = false
                var timesTriggered = 0

                player.core?.on(Event.willLoadSource.rawValue) { _ in
                    willLoadSourceTriggered = true
                    timesTriggered += 1
                }

                player.load(PlayerTests.specialSource)

                expect(willLoadSourceTriggered).to(beTrue())
                expect(timesTriggered).toEventually(equal(1))
            }
            
            describe("Player chromeless") {
                context("when in chromeless mode") {
                    it("hide playback controls") {
                        let player = Player(options:[kChromeless: true])
                        
                        player.viewDidLoad()
                        
                        expect(player.showsPlaybackControls).to(beFalse())
                    }
                    
                    it("autoplay when app returns from background") {
                        Loader.shared.resetPlaybacks()
                        Player.register(playbacks: [FakeAVFoundationPlaybackMock.self])
                        let player = Player(options:[kSourceUrl:"http://sitedoesnotexist.co.ce", kChromeless: true])
                        let playback = player.activePlayback as? FakeAVFoundationPlaybackMock
                        
                        player.viewDidLoad()
                        
                        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
                        
                        expect(playback?.didCallPlay).toEventually(beTrue())
                    }
                }
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

class FakeAVFoundationPlaybackMock: AVFoundationPlayback {
    var didCallPlay = false
    
    override func play() {
        didCallPlay = true
    }
    
    override func render() { }
    
    override class func canPlay(_: Options) -> Bool {
        return true
    }
}

class AContainerPlugin : ContainerPlugin {
    override class var name: String {
        return "AContainerPlugin"
    }
}

class AnUICorePlugin: UICorePlugin {
    override class var name: String {
        return "AnUICorePlugin"
    }

    override func bindEvents() { }

    override func render() {
        view = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
}
