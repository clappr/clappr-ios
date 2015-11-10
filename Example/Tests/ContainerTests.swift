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
            }
        }
    }
}