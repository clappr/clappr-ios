import Quick
import Nimble
import Clappr

class ContainerTests: QuickSpec {
    
    override func spec() {
        describe("Container") {
            let options = [kSourceUrl : "http://clappr.com/video.mp4"]
            let optionsWithInvalidSource = [kSourceUrl : "invalid"]

            var container: Container!
            var playback: StubPlayback!
            var loader: Loader!

            beforeEach() {
                loader = Loader()
                loader.addExternalPlugins([StubPlayback.self])
                playback = StubPlayback(options: options)
                container = Container(playback: playback)
            }
            
            describe("Initialization") {
                it("Should have the playback as subview after rendered") {
                    container.render()
                    expect(playback.superview) == container
                }
                
                it("Should have a constructor that receive options") {
                    let options = ["aOption" : "option"]
                    let container = Container(playback: playback, options: options)
                    
                    let option = container.options["aOption"] as! String
                    
                    expect(option) == "option"
                }

                it("Should add container plugins from loader") {
                    loader.addExternalPlugins([FakeContainerPlugin.self, AnotherFakeContainerPlugin.self])

                    let container = Container(playback: playback, loader: loader, options: options)

                    expect(container.hasPlugin(FakeContainerPlugin)).to(beTrue())
                    expect(container.hasPlugin(AnotherFakeContainerPlugin)).to(beTrue())
                }

                it("Should add a container context to all plugins") {
                    let container = Container(playback: playback, loader: loader, options: optionsWithInvalidSource)

                    expect(container.plugins).toNot(beEmpty())

                    for plugin in container.plugins {
                        expect(plugin.container) == container
                    }
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
                    let expectedStart: Float = 0.7, expectedEnd: Float = 15.4, expectedDuration: NSTimeInterval = 10
                    var start: Float!, end: Float!, duration: NSTimeInterval!
                    
                    container.once(ContainerEvent.Progress.rawValue) { userInfo in
                        start = userInfo?["start_position"] as! Float
                        end = userInfo?["end_position"] as! Float
                        duration = userInfo?["duration"] as! NSTimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["start_position": expectedStart,
                        "end_position": expectedEnd,
                        "duration": expectedDuration]
                    playback.trigger(PlaybackEvent.Progress.rawValue, userInfo: userInfo)
                    
                    expect(start) == expectedStart
                    expect(end) == expectedEnd
                    expect(duration) == expectedDuration
                }
                
                it("Should trigger container time updated event when playback respective event happens") {
                    let expectedPosition: Float = 10.3, expectedDuration: NSTimeInterval = 12.7
                    var position: Float!, duration: NSTimeInterval!
                    
                    container.once(ContainerEvent.TimeUpdated.rawValue) { userInfo in
                        position = userInfo?["position"] as! Float
                        duration = userInfo?["duration"] as! NSTimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["position": expectedPosition, "duration": expectedDuration]
                    playback.trigger(PlaybackEvent.TimeUpdated.rawValue, userInfo: userInfo)
                    
                    expect(position) == expectedPosition
                    expect(duration) == expectedDuration
                }
                
                it("Should trigger container loaded metadata event when playback respective event happens") {
                    let expectedDuration: NSTimeInterval = 20.0
                    var duration: NSTimeInterval!
                    
                    container.once(ContainerEvent.LoadedMetadata.rawValue) { userInfo in
                        duration = userInfo?["duration"] as! NSTimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["duration": expectedDuration]
                    playback.trigger(PlaybackEvent.LoadedMetadata.rawValue, userInfo: userInfo)
                    
                    expect(duration) == expectedDuration
                }
                
                it("Should trigger container bit rate event when playback respective event happens") {
                    let expectedBitRate: NSTimeInterval = 11.0
                    var bitRate: NSTimeInterval!
                    
                    container.once(ContainerEvent.BitRate.rawValue) { userInfo in
                        bitRate = userInfo?["bit_rate"] as! NSTimeInterval
                    }
                    
                    let userInfo: EventUserInfo = ["bit_rate": expectedBitRate]
                    playback.trigger(PlaybackEvent.BitRate.rawValue, userInfo: userInfo)
                    
                    expect(bitRate) == expectedBitRate
                }
                
                it("Should trigger container DVR state event when playback respective event happens with params") {
                    var dvrInUse = false
                    
                    container.once(ContainerEvent.PlaybackDVRStateChanged.rawValue) { userInfo in
                        dvrInUse = userInfo?["dvr_in_use"] as! Bool
                    }
                    
                    let userInfo: EventUserInfo = ["dvr_in_use": true]
                    playback.trigger(PlaybackEvent.DVRStateChanged.rawValue, userInfo: userInfo)
                    
                    expect(dvrInUse).to(beTrue())
                }
                
                it("Should trigger container Error event when playback respective event happens with params") {
                    var error = ""
                    
                    container.once(ContainerEvent.Error.rawValue) { userInfo in
                        error = userInfo?["error"] as! String
                    }
                    
                    let userInfo: EventUserInfo = ["error": "Error"]
                    playback.trigger(PlaybackEvent.Error.rawValue, userInfo: userInfo)
                    
                    expect(error) == "Error"
                }
                
                it("Should update container dvrInUse property on playback DVRSTateChanged event") {
                    let userInfo: EventUserInfo = ["dvr_in_use": true]
                    
                    expect(container.dvrInUse).to(beFalse())
                    playback.trigger(PlaybackEvent.DVRStateChanged.rawValue, userInfo: userInfo)
                    expect(container.dvrInUse).to(beTrue())
                }
                
                it("Should be ready after playback ready event is triggered") {
                    expect(container.ready) == false
                    playback.trigger(PlaybackEvent.Ready.rawValue)
                    expect(container.ready) == true
                }
                
                it("Should trigger buffering event after playback respective event is triggered") {
                    container.on(ContainerEvent.Buffering.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.Buffering.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger buffer full event after playback respective event is triggered") {
                    container.on(ContainerEvent.BufferFull.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.BufferFull.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger settings event after playback respective event is triggered") {
                    container.on(ContainerEvent.SettingsUpdated.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.SettingsUpdated.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger HD updated event after playback respective event is triggered") {
                    container.on(ContainerEvent.HighDefinitionUpdated.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.HighDefinitionUpdated.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger State Changed event after playback respective event is triggered") {
                    container.on(ContainerEvent.PlaybackStateChanged.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.StateChanged.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger Media Control Disabled event after playback respective event is triggered") {
                    container.on(ContainerEvent.MediaControlDisabled.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.MediaControlDisabled.rawValue)
                    expect(eventWasTriggered) == true
                }

                it("Should trigger Media Control Enabled event after playback respective event is triggered") {
                    container.on(ContainerEvent.MediaControlEnabled.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.MediaControlEnabled.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should update mediaControlEnabled property after playback MediaControleEnabled or Disabled is triggered") {
                    playback.trigger(PlaybackEvent.MediaControlEnabled.rawValue)
                    expect(container.mediaControlEnabled).to(beTrue())
                    playback.trigger(PlaybackEvent.MediaControlDisabled.rawValue)
                    expect(container.mediaControlEnabled).to(beFalse())
                }
                
                it("Should trigger Ended event after playback respective event is triggered") {
                    container.on(ContainerEvent.Ended.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.Ended.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger Play event after playback respective event is triggered") {
                    container.on(ContainerEvent.Play.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.Play.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger Pause event after playback respective event is triggered") {
                    container.on(ContainerEvent.Pause.rawValue, callback: eventCallback)
                    playback.trigger(PlaybackEvent.Pause.rawValue)
                    expect(eventWasTriggered) == true
                }
                
                it("Should trigger it's Stop event after stop is called") {
                    container.on(ContainerEvent.Stop.rawValue, callback: eventCallback)
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
                            return ["foo": "bar"]
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
                        mockedPlayback = MockedSettingsPlayback(options: options)
                        container = Container(playback: mockedPlayback)
                    }
                    
                    it("Should update it's settings after playback's settings update event") {
                        mockedPlayback.trigger(PlaybackEvent.SettingsUpdated.rawValue)
                        let fooSetting = container.settings["foo"] as? String
                        expect(fooSetting) == "bar"
                    }
                    
                    it("Should update it's settings after playback's DVR State changed event") {
                        mockedPlayback.trigger(PlaybackEvent.DVRStateChanged.rawValue)
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
                    let options = [kStartAt : 15]
                    let container = Container(playback: StubPlayback(options: options), options: options)

                    expect(container.options[kStartAt] as? Int) == 15
                    expect(container.playback.startAt) == 15

                    container.playback.play()
                    container.load("http://clappr.com/video.mp4")

                    expect(container.options[kStartAt] as? Int) == 0
                    expect(container.playback.startAt) == 0
                }
            }
        }
    }
    
    class StubPlayback: Playback {
        override var pluginName: String {
            return "stubPlayback"
        }

        override func play() {
            trigger(PlayerEvent.Play.rawValue)
        }
    }

    class FakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "FakeContainerPlugin"
        }
    }

    class AnotherFakeContainerPlugin: UIContainerPlugin {
        override var pluginName: String {
            return "AnotherFakeContainerPlugin"
        }
    }
}
