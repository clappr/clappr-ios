import Quick
import Nimble
import Clappr

class ContainerTests: QuickSpec {
    
    override func spec() {
        describe("Container") {
            var container: Container!
            var playback: Playback!
            let sourceURL = NSURL(string: "http://globo.com/video.mp4")!
            
            beforeEach() {
                playback = Playback(url: sourceURL)
                container = Container(playback: playback)
            }
            
            describe("Initialization") {
                it("Should have the playback as subview") {
                    expect(playback.superview) == container
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
                
            }
        }
    }
}