import Quick
import Nimble
import Clappr

class ContainerTests: QuickSpec {
    
    override func spec() {
        describe("Container") {
            var container: Container!
            var playback: StubPlayback!
            let options = [kSourceUrl : "http://clappr.com/video.mp4"]
            
            beforeEach() {
                playback = StubPlayback(options: options as Options)
                container = Container(playback: playback)
            }
            
            describe("Initialization") {
                it("Should have the playback as subview after rendered") {
                    container.render()
                    expect(playback.superview) == container
                }
                
                it("Should have a constructor that receive options") {
                    let options = ["aOption" : "option"]
                    let container = Container(playback: playback, options: options as Options)
                    
                    let option = container.options["aOption"] as! String
                    
                    expect(option) == "option"
                }
            }
            
            describe("Destroy") {
                it("Should be removed from superview and destroy playback when destroy is called") {
                    let wrapperView = UIView()
                    wrapperView.addSubview(container)
                    
                    container.destroy()
                    
                    expect(playback.superview).to(beNil())
                    expect(container.superview).to(beNil())
                }
                
                it("Should stop listening to events after destroy is called") {
                    var callbackWasCalled = false
                    container.on("some-event") { _ in
                        callbackWasCalled = true
                    }
                    
                    container.destroy()
                    container.trigger("some-event")
                    
                    expect(callbackWasCalled) == false
                }
            }
            
            describe("Event Binding") {
                var eventWasTriggered = false
                let eventCallback: EventCallback = { _ in
                    eventWasTriggered = true
                }
                
                beforeEach{
                    eventWasTriggered = false
                }
                
                
                it("Should trigger container progress event when playback progress event happens") {
                    let expectedStart: Float = 0.7, expectedEnd: Float = 15.4, expectedDuration: TimeInterval = 10
                    var start: Float!, end: Float!, duration: TimeInterval!
                    
                    container.once(ContainerEvent.progress.rawValue) { userInfo in
                        start = userInfo?["start_position"] as! Float
                        end = userInfo?["end_position"] as! Float
                        duration = userInfo?["duration"] as! TimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["start_position": expectedStart,
                        "end_position": expectedEnd,
                        "duration": expectedDuration]
                    playback.trigger(PlaybackEvent.progress.rawValue, userInfo: userInfo)
                    
                    expect(start) == expectedStart
                    expect(end) == expectedEnd
                    expect(duration) == expectedDuration
                }
                
                it("Should trigger container time updated event when playback respective event happens") {
                    let expectedPosition: Float = 10.3, expectedDuration: TimeInterval = 12.7
                    var position: Float!, duration: TimeInterval!
                    
                    container.once(ContainerEvent.timeUpdated.rawValue) { userInfo in
                        position = userInfo?["position"] as! Float
                        duration = userInfo?["duration"] as! TimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["position": expectedPosition, "duration": expectedDuration]
                    playback.trigger(PlaybackEvent.timeUpdated.rawValue, userInfo: userInfo)
                    
                    expect(position) == expectedPosition
                    expect(duration) == expectedDuration
                }
                
                it("Should trigger container loaded metadata event when playback respective event happens") {
                    let expectedDuration: TimeInterval = 20.0
                    var duration: TimeInterval!
                    
                    container.once(ContainerEvent.loadedMetadata.rawValue) { userInfo in
                        duration = userInfo?["duration"] as! TimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["duration": expectedDuration]
                    playback.trigger(PlaybackEvent.loadedMetadata.rawValue, userInfo: userInfo)
                    
                    expect(duration) == expectedDuration
                }
                
                it("Should trigger container bit rate event when playback respective event happens") {
                    let expectedBitRate: TimeInterval = 11.0
                    var bitRate: TimeInterval!
                    
                    container.once(ContainerEvent.bitRate.rawValue) { userInfo in
                        bitRate = userInfo?["bit_rate"] as! TimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["bit_rate": expectedBitRate]
                    playback.trigger(PlaybackEvent.bitRate.rawValue, userInfo: userInfo)
                    
                    expect(bitRate) == expectedBitRate
                }
                
                it("Should trigger container DVR state event when playback respective event happens with params") {
                    var dvrInUse = false
                    
                    container.once(ContainerEvent.playbackDVRStateChanged.rawValue) { userInfo in
                        dvrInUse = userInfo?["dvr_in_use"] as! Bool
                    }
                    
                    let userInfo: EventUserInfo = ["dvr_in_use": true]
                    playback.trigger(PlaybackEvent.dvrStateChanged.rawValue, userInfo: userInfo)
                    
                    expect(dvrInUse).to(beTrue())
                }
                
                it("Should trigger container Error event when playback respective event happens with params") {
                    var error = ""
                    
                    container.once(ContainerEvent.error.rawValue) { userInfo in
                        error = userInfo?["error"] as! String
                    }
                    
                    let userInfo: EventUserInfo = ["error": "Error"]
                    playback.trigger(PlaybackEvent.error.rawValue, userInfo: userInfo)
                    
                    expect(error) == "Error"
                }
                
                it("Should update container dvrInUse property on playback DVRSTateChanged event") {
                    let userInfo: EventUserInfo = ["dvr_in_use": true]
                    
                    expect(container.dvrInUse).to(beFalse())
                    playback.trigger(PlaybackEvent.dvrStateChanged.rawValue, userInfo: userInfo)
                    expect(container.dvrInUse).to(beTrue())
                }
                
                it("Should be ready after playback ready event is triggered") {
                    expect(container.ready) == false
                    playback.trigger(PlaybackEvent.ready.rawValue)
                    expect(container.ready) == true
                }
                
                it("Should trigger buffering event after playback respective event is triggered") {
                    container.on(ContainerEvent.buffering.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.buffering.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger buffer full event after playback respective event is triggered") {
                    container.on(ContainerEvent.bufferFull.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.bufferFull.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger settings event after playback respective event is triggered") {
                    container.on(ContainerEvent.settingsUpdated.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.settingsUpdated.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger HD updated event after playback respective event is triggered") {
                    container.on(ContainerEvent.highDefinitionUpdated.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.highDefinitionUpdated.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger State Changed event after playback respective event is triggered") {
                    container.on(ContainerEvent.playbackStateChanged.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.stateChanged.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger Media Control Disabled event after playback respective event is triggered") {
                    container.on(ContainerEvent.mediaControlDisabled.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.mediaControlDisabled.rawValue)
                    expect(eventWasTriggered) == true
                }

                it("Should trigger Media Control Enabled event after playback respective event is triggered") {
                    container.on(ContainerEvent.mediaControlEnabled.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.mediaControlEnabled.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should update mediaControlEnabled property after playback MediaControleEnabled or Disabled is triggered") {
                    playback.trigger(PlaybackEvent.mediaControlEnabled.rawValue)
                    expect(container.mediaControlEnabled).to(beTrue())
                    playback.trigger(PlaybackEvent.mediaControlDisabled.rawValue)
                    expect(container.mediaControlEnabled).to(beFalse())
                }
                
                it("Should trigger Ended event after playback respective event is triggered") {
                    container.on(ContainerEvent.ended.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.ended.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger Play event after playback respective event is triggered") {
                    container.on(ContainerEvent.play.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.play.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger Pause event after playback respective event is triggered") {
                    container.on(ContainerEvent.pause.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.pause.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger it's Stop event after stop is called") {
                    container.on(ContainerEvent.stop.rawValue, callback: eventCallback)
                    container.stop()
                    expect(eventWasTriggered) == true
                }
                
                context("Bindings with mocked playback") {
                    class MockedSettingsPlayback: Playback {
                        override var pluginName: String {
                            return "mockedPlayback"
                        }
                        
                        var stopWasCalled = false , playWasCalled = false, pauseWasCalled = false

                        override var settings: [String: AnyObject] {
                            return ["foo": "bar" as AnyObject]
                        }
                        
                        override var isPlaying: Bool {
                            return true
                        }
                        
                        override func stop() {
                            stopWasCalled = true
                        }
                        
                        override func pause() {
                            pauseWasCalled = true
                        }
                        
                        override func play() {
                            playWasCalled = true
                        }
                    }
                    
                    var mockedPlayback: MockedSettingsPlayback!
                    
                    beforeEach() {
                        mockedPlayback = MockedSettingsPlayback(options: options as Options)
                        container = Container(playback: mockedPlayback)
                    }
                    
                    it("Should update it's settings after playback's settings update event") {
                        mockedPlayback.trigger(PlaybackEvent.settingsUpdated.rawValue)
                        let fooSetting = container.settings["foo"] as? String
                        expect(fooSetting) == "bar"
                    }
                    
                    it("Should update it's settings after playback's DVR State changed event") {
                        mockedPlayback.trigger(PlaybackEvent.dvrStateChanged.rawValue)
                        let fooSetting = container.settings["foo"] as? String
                        expect(fooSetting) == "bar"
                    }
                    
                    it("Should call playback's stop method after calling respective method on container") {
                        container.stop()
                        expect(mockedPlayback.stopWasCalled).to(beTrue())
                    }
                    
                    it("Should call playback's play method after calling respective method on container") {
                        container.play()
                        expect(mockedPlayback.playWasCalled).to(beTrue())
                    }
                    
                    it("Should call playback's pause method after calling respective method on container") {
                        container.pause()
                        expect(mockedPlayback.pauseWasCalled).to(beTrue())
                    }
                    
                    it("Should return playback 'isPlaying' status when respective property is accessed") {
                        expect(container.isPlaying) == mockedPlayback.isPlaying
                    }
                }
            }
            
            describe("Plugins") {
                class FakeUIContainerPlugin: UIContainerPlugin {}
                class AnotherUIContainerPlugin: UIContainerPlugin {}
                
                it("Should be able to add a new container UIPlugin") {
                    container.addPlugin(FakeUIContainerPlugin())
                    expect(container.plugins).toNot(beEmpty())
                }
                
                it("Should be able to check if has a plugin with given class") {
                    container.addPlugin(FakeUIContainerPlugin())
                    expect(container.hasPlugin(FakeUIContainerPlugin)).to(beTrue())
                }
                
                it("Should return false if plugin isn't on container") {
                    container.addPlugin(FakeUIContainerPlugin())
                    expect(container.hasPlugin(AnotherUIContainerPlugin)).to(beFalse())
                }
                
                it("Should not add self reference on the plugin") {
                    let plugin = FakeUIContainerPlugin()
                    container.addPlugin(plugin)
                    expect(plugin.container).to(beNil())
                }
                
                it("Should instantiate plugin with self reference") {
                    let plugin = FakeUIContainerPlugin(context: container)
                    container.addPlugin(plugin)
                    expect(plugin.container) == container
                }

                it("Should add plugin as subview after rendered") {
                    let plugin = FakeUIContainerPlugin()
                    container.addPlugin(plugin)
                    container.render()
                    
                    expect(plugin.superview) == container
                }
            }
            
            describe("Source") {
                it("Should be able to load a source") {
                    let container = Container(playback: NoOpPlayback(options: [:]))

                    expect(container.playback.pluginName) == "NoOp"

                    container.load("http://clappr.com/video.mp4")

                    expect(container.playback.pluginName) == "AVPlayback"
                    expect(container.playback.superview) == container
                }
                
                it("Should be able to load a source with mime type") {
                    let container = Container(playback: NoOpPlayback(options: [:]))
                    
                    expect(container.playback.pluginName) == "NoOp"
                    
                    container.load("http://clappr.com/video", mimeType: "video/mp4")
                    
                    expect(container.playback.pluginName) == "AVPlayback"
                    expect(container.playback.superview) == container
                }
            }

            describe("Options") {
                it("Should reset startAt after first play event") {
                    let options = [kStartAt : 15.0]
                    let container = Container(playback: StubPlayback(options: options as Options), options: options as Options)

                    expect(container.options[kStartAt] as? Double) == 15.0
                    expect(container.playback.startAt) == 15.0

                    container.playback.play()
                    container.load("http://clappr.com/video.mp4")

                    expect(container.options[kStartAt] as? Double) == 0.0
                    expect(container.playback.startAt) == 0.0
                }
            }
        }
    }
    
    class StubPlayback: Playback {
        override var pluginName: String {
            return "stubPlayback"
        }

        override func play() {
            trigger(PlayerEvent.play.rawValue)
        }
    }
}
