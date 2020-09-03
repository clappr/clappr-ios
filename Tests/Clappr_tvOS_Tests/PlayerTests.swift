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
            
            describe("Player focus") {
                context("when an view is the first to request focus") {
                    context("the item is focusable") {
                        it("changes focus to itself") {
                            let player = Player(options: [kMediaControl: true])
                            let button = UIButton()
                            button.tag = 1234
                            player.core?.view.addSubview(button)
                            player.viewDidLoad()

                            self.requestFocus(button, baseObject: player.core)
                            
                            let focusedView = player.preferredFocusEnvironments.first as? UIView
                            expect(focusedView).to(be(button))
                        }
                    }
                    
                    context("the item is not focusable") {
                        it("doesn't change focus to itself") {
                            let player = Player(options: [kMediaControl: true])
                            let button = UIButton()
                            button.tag = 5678
                            button.isHidden = true
                            player.core?.view.addSubview(button)
                            player.viewDidLoad()
                            
                            self.requestFocus(button, baseObject: player.core)
                            
                            let focusedView = player.preferredFocusEnvironments.first as? UIView
                            expect(focusedView).toNot(be(button))
                        }
                    }
                }
                
                context("when an view release focus") {
                    context("and focus is itself") {
                        it("releases the focus") {
                            let player = Player(options: [kMediaControl: true])
                            let button = UIButton()
                            button.tag = 12345
                            player.core?.view.addSubview(button)
                            player.viewDidLoad()
                            
                            self.requestFocus(button, baseObject: player.core)
                            self.releaseFocus(button, baseObject: player.core)
                            
                            let focusedView = player.preferredFocusEnvironments.first as? UIView
                            expect(focusedView).toNot(be(button))
                        }
                    }
                    
                    context("and focus is not itself") {
                        it("doesn't release the focus") {
                            let player = Player(options: [kMediaControl: true])
                            let button = UIButton()
                            let buttonWithoutFocus = UIButton()
                            button.tag = 123456
                            buttonWithoutFocus.tag = 7890
                            player.core?.view.addSubview(button)
                            player.core?.view.addSubview(buttonWithoutFocus)
                            player.viewDidLoad()

                            self.requestFocus(button, baseObject: player.core)
                            self.releaseFocus(buttonWithoutFocus, baseObject: player.core)
                            
                            let focusedView = player.preferredFocusEnvironments.first as? UIView
                            expect(focusedView).to(be(button))
                        }
                    }
                }
                
                context("when an view is not the first to request focus") {
                    context("and the focus was released") {
                        it("changes focus to itself") {
                            let player = Player(options: [kMediaControl: true])
                            let button = UIButton()
                            let anotherButton = UIButton()
                            button.tag = 111
                            anotherButton.tag = 222
                            player.core?.view.addSubview(button)
                            player.core?.view.addSubview(anotherButton)
                            player.viewDidLoad()
                            self.requestFocus(button, baseObject: player.core)
                            self.releaseFocus(button, baseObject: player.core)
                            
                            self.requestFocus(anotherButton, baseObject: player.core)
                            
                            let focusedView = player.preferredFocusEnvironments.first as? UIView
                            expect(focusedView).to(be(anotherButton))
                        }
                    }
                    
                    context("and the focus was not released") {
                        it("doesn't change focus to itself") {
                            let player = Player(options: [kMediaControl: true])
                            let button = UIButton()
                            let anotherButton = UIButton()
                            button.tag = 111
                            anotherButton.tag = 222
                            player.core?.view.addSubview(button)
                            player.core?.view.addSubview(anotherButton)
                            player.viewDidLoad()
                            self.requestFocus(button, baseObject: player.core)
                            
                            self.requestFocus(anotherButton, baseObject: player.core)
                            
                            let focusedView = player.preferredFocusEnvironments.first as? UIView
                            expect(focusedView).to(be(button))
                        }
                    }
                }
            }

            describe("#chromeless") {
                context("when enter chromeless mode is call") {
                    it("enables the chromeless mode") {
                        let player = Player()

                        player.enterChromelessMode()

                        expect(player.isChromelessModeEnabled).to(beTrue())
                    }

                    it("triggers the didEnterChromelessMode event") {
                        var didEnterChromelessModeEventCalled = false
                        let player = Player()

                        player.core?.on(InternalEvent.didEnterChromelessMode.rawValue) { _ in
                            didEnterChromelessModeEventCalled = true
                        }

                        player.enterChromelessMode()

                        expect(didEnterChromelessModeEventCalled).to(beTrue())
                    }
                }

                context("when exit chromeless mode is call") {
                    it("disables the chromeless mode") {
                        let player = Player()
                        player.enterChromelessMode()

                        player.exitChromelessMode()

                        expect(player.isChromelessModeEnabled).to(beFalse())
                    }

                    it("triggers the didExitChromelessMode event") {
                        var didExitChromelessModeEventCalled = false
                        let player = Player()

                        player.core?.on(InternalEvent.didExitChromelessMode.rawValue) { _ in
                            didExitChromelessModeEventCalled = true
                        }

                        player.exitChromelessMode()

                        expect(didExitChromelessModeEventCalled).to(beTrue())
                    }
                }
            }
        }
    }
    
    private func requestFocus(_ view: UIView, baseObject: BaseObject?) {
        let userInfo: EventUserInfo = ["viewTag": view.tag]

        baseObject?.trigger(.requestFocus, userInfo: userInfo)
    }

    private func releaseFocus(_ view: UIView, baseObject: BaseObject?) {
        let userInfo: EventUserInfo = ["viewTag": view.tag]

        baseObject?.trigger(.releaseFocus, userInfo: userInfo)
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
