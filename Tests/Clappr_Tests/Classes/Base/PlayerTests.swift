import Quick
import Nimble
import AVFoundation

@testable import Clappr

class PlayerTests: QuickSpec {
    static let specialSource = "specialSource"

    override func spec() {
        describe(".Player") {
            let options: Options = [kSourceUrl: "http://clappr.com/video.mp4"]
            var player: Player!
            var playback: Playback!

            context("#init") {
                context("when listening Playback events") {
                    var callbackWasCalled = false

                    beforeEach {
                        Loader.shared.resetPlugins()
                        Player.register(playbacks: [SpecialStubPlayback.self, StubPlayback.self])
                        player = Player(options: options)
                        playback = player.activePlayback
                        callbackWasCalled = false
                    }

                    it("calls a callback function to handle ready event") {
                        player.on(.ready) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.ready)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle error event") {
                        player.on(.error) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.error)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didComplete event") {
                        player.on(.didComplete) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didComplete)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didPause event") {
                        player.on(.didPause) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didPause)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didStop event") {
                        player.on(.didStop) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didStop)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle stalling event") {
                        player.on(.stalling) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.stalling)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didUpdateBuffer event") {
                        player.on(.didUpdateBuffer) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdateBuffer)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didUpdatePosition event") {
                        player.on(.didUpdatePosition) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdatePosition)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didUpdateAirPlayStatus event") {
                        player.on(.didUpdateAirPlayStatus) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdateAirPlayStatus)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willPlay event") {
                        player.on(.willPlay) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willPlay)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle playing event") {
                        player.on(.playing) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.playing)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willPause event") {
                        player.on(.willPause) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willPause)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willStop event") {
                        player.on(.willStop) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willStop)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willSeek event") {
                        player.on(.willSeek) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willSeek)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didSeek event") {
                        player.on(.didSeek) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didSeek)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didSelectSubtitle event") {
                        player.on(.didSelectSubtitle) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didSelectSubtitle)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didSelectAudio event") {
                        player.on(.didSelectAudio) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didSelectAudio)

                        expect(callbackWasCalled).to(beTrue())
                    }
                    
                    it("calls a callback function to handle didUpateBitrate event") {
                        player.on(.didUpdateBitrate) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdateBitrate)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("when listening to core events") {
                    var callbackWasCalled = false
                       
                    beforeEach {
                        player = Player(options: options)
                        callbackWasCalled = false
                    }
                       
                    it("calls a callback function to handle willShowMediaControl") {
                        player.on(.willShowMediaControl) { _ in
                            callbackWasCalled = true
                        }
                        player.core?.trigger(.willShowMediaControl)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                    
                    it("calls a callback function to handle didShowMediaControl") {
                        player.on(.didShowMediaControl) { _ in
                            callbackWasCalled = true
                        }
                        player.core?.trigger(.didShowMediaControl)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                    
                    it("calls a callback function to handle willHideMediaControl") {
                        player.on(.willHideMediaControl) { _ in
                            callbackWasCalled = true
                        }
                        player.core?.trigger(.willHideMediaControl)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                    
                    it("calls a callback function to handle didHideMediaControl") {
                        player.on(.didHideMediaControl) { _ in
                            callbackWasCalled = true
                        }
                        player.core?.trigger(.didHideMediaControl)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }

                context("core dependency") {
                    it("is initialized") {
                        let player = Player(options: options)
                        expect(player.core).toNot(beNil())
                    }

                    it("has active container") {
                        let player = Player(options: options)
                        expect(player.core?.activeContainer).toNot(beNil())
                    }
                }

                context("external playbacks") {
                    it("sets external playback as active") {
                        Loader.shared.resetPlaybacks()
                        Player.register(playbacks: [StubPlayback.self])
                        let player = Player(options: [kSourceUrl: "video"])

                        expect(player.activePlayback).to(beAKindOf(StubPlayback.self))
                    }

                    it("changes external playback based on source") {
                        Loader.shared.resetPlaybacks()
                        Player.register(playbacks: [SpecialStubPlayback.self])
                        let player = Player(options: options)

                        player.load(PlayerTests.specialSource)

                        expect(player.activePlayback).to(beAKindOf(SpecialStubPlayback.self))
                    }

                    it("triggers willLoadSource in core") {
                        Loader.shared.resetPlaybacks()
                        Player.register(playbacks: [SpecialStubPlayback.self])
                        let player = Player(options: options)
                        var willLoadSourceTriggered = false

                        player.core?.on(Event.willLoadSource.rawValue) { _ in
                            willLoadSourceTriggered = true
                        }

                        player.load(PlayerTests.specialSource)

                        expect(willLoadSourceTriggered).to(beTrue())
                    }
                }

                context("third party plugins") {
                    it("pass plugins to core") {
                        Loader.shared.resetPlugins()

                        Player.register(plugins: [LoggerPlugin.self])
                        player = Player(options: options)

                        let loggerPlugin = player.getPlugin(name: LoggerPlugin.name)
                        expect(loggerPlugin).to(beAKindOf(LoggerPlugin.self))
                    }
                    
                    it("pass plugins to container") {
                        Loader.shared.resetPlugins()
                        
                        Player.register(plugins: [FakeContainerPlugin.self])
                        player = Player(options: options)
                        
                        let fakeContainerPlugin = player.getPlugin(name: FakeContainerPlugin.name)
                        expect(fakeContainerPlugin).to(beAKindOf(FakeContainerPlugin.self))
                    }

                    it("pass plugins to Loader") {
                        Loader.shared.resetPlugins()

                        Player.register(plugins: [LoggerPlugin.self])
                        player = Player(options: options)

                        let loggerPlugin = Loader.shared.corePlugins.first { $0.name == LoggerPlugin.name }
                        expect(loggerPlugin).to(beAKindOf(LoggerPlugin.Type.self))
                    }

                    it("ignore plugins registered after player initialization") {
                        Loader.shared.resetPlugins()
                        Player.register(playbacks: [SpecialStubPlayback.self, StubPlayback.self])
                        player = Player(options: options)

                        Player.register(plugins: [LoggerPlugin.self])

                        let loggerPlugin = player.getPlugin(name: LoggerPlugin.name)
                        expect(loggerPlugin).to(beNil())
                    }
                }
            }

            describe("#configure") {
                it("changes Core options") {
                    Loader.shared.resetPlugins()
                    Player.register(playbacks: [SpecialStubPlayback.self, StubPlayback.self])
                    player = Player(options: options)
                    player.configure(options: ["foo": "bar"])

                    let playerOptionValue = player.core?.options["foo"] as? String

                    expect(playerOptionValue).to(equal("bar"))
                }

                it("triggers willLoadSource in core on load") {
                    Loader.shared.resetPlaybacks()
                    Player.register(playbacks: [SpecialStubPlayback.self])
                    let player = Player(options: options)
                    var willLoadSourceTriggered = false

                    player.core?.on(Event.willLoadSource.rawValue) { _ in
                        willLoadSourceTriggered = true
                    }

                    player.load(PlayerTests.specialSource)

                    expect(willLoadSourceTriggered).to(beTrue())
                }
            }

            describe("#attachTo") {
                it("triggers didAttachView") {
                    let player = Player(options: [:])
                    let view = UIView(frame: .zero)
                    let controller = UIViewController()

                    var didTriggerEvent = false
                    player.listenTo(player.core!, eventName: Event.didAttachView.rawValue) { _ in
                        didTriggerEvent = true
                    }

                    player.attachTo(view, controller: controller)

                    expect(didTriggerEvent).to(beTrue())
                }
            }

            describe("lifecycle") {
                it("triggers events of destruction correctly") {
                    var triggeredEvents = [String]()
                    player = Player(options: options)
                    player.listenTo(player.core!, eventName: Event.didDestroy.rawValue) { _ in
                        triggeredEvents.append("core")
                    }
                    player.listenTo(player.activeContainer!, eventName: Event.didDestroy.rawValue) { _ in
                        triggeredEvents.append("container")
                    }
                    player.destroy()

                    expect(triggeredEvents).toEventually(equal(["container", "core"]))
                    expect(player.core).to(beNil())
                    expect(player.activeContainer).to(beNil())
                }
            }
            
            context("when in Chromeless mode") {
                let options: Options = [kSourceUrl: "http://sitedoesnotexist.com.br/",
                                        kChromeless: true]
                Loader.shared.resetPlugins()
                Player.register(playbacks: [StubPlayback.self])
                let player = Player(options: options)
                let playback = player.activePlayback as? StubPlayback
                
                it("auto play when come from background") {
                    playback?.didCallPlay = false
                    
                    NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
                    
                    expect(playback?.didCallPlay).to(beTrue())
                }
            }
            
            context("when not in Chromeless mode") {
                let options: Options = [kSourceUrl: "http://sitedoesnotexist.com.br/"]
                Loader.shared.resetPlugins()
                Player.register(playbacks: [StubPlayback.self])
                let player = Player(options: options)
                let playback = player.activePlayback as? StubPlayback
                
                it("does not auto play when come from background") {
                    playback?.didCallPlay = false
                    
                    NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
                    
                    expect(playback?.didCallPlay).to(beFalse())
                }
            }
        }
    }

    class StubPlayback: Playback {
        var didCallPlay = false
        var didCallStop = false
        
        override class var name: String {
            return "StubPlayback"
        }
        
        override func play() {
            didCallPlay = true
        }
        
        override func stop() {
            didCallStop = true
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

    class LoggerPlugin: UICorePlugin {
        override class var name: String { return "Logger" }

        required init(context: UIObject) {
            super.init(context: context)
        }

        override public func bindEvents() {
            bindPlaybackEvents()
        }

        private func bindPlaybackEvents() {
            if let core = self.core {
                listenTo(core, eventName: Event.didChangeActivePlayback.rawValue) {  (_: EventUserInfo) in
                    print("Log didChangeActivePlayback!!!!")
                }
            }
        }
    }
    
    class FakeContainerPlugin: UIContainerPlugin {
        override class var name: String {
            return "FakeContainerPlugin"
        }

        override func bindEvents() { }
    }
}
