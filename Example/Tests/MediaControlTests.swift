import Quick
import Nimble
import Clappr

class MediaControlTests: QuickSpec {
    
    override func spec() {
        describe("MediaControl") {
            let sourceUrl = NSURL(string: "http://globo.com/video.mp4")!
            var container: Container!
            var playback: StubedPlayback!
            
            beforeEach() {
                playback = StubedPlayback(url: sourceUrl)
                container = Container(playback: playback)
            }
            
            context("Initialization") {
                
                it("Should have a init method to setup with container") {
                    let mediaControl = MediaControl.initFromNib()
                    mediaControl.setup(container)
                    
                    expect(mediaControl).toNot(beNil())
                    expect(mediaControl.container) == container
                }
            }
            
            context("Behavior") {
                var mediaControl: MediaControl!
                
                beforeEach() {
                    mediaControl = MediaControl.initFromNib()
                    mediaControl.setup(container)
                }
                
                context("Visibility") {
                    it("Should start with controls hidden") {
                        expect(mediaControl.controlsOverlayView.alpha) == 0
                        expect(mediaControl.controlsWrapperView.alpha) == 0
                        expect(mediaControl.controlsHidden).to(beTrue())
                    }
                    
                    it("Should show it's control after when media control is enabled on container") {
                        container.mediaControlEnabled = true
                        
                        expect(mediaControl.controlsOverlayView.alpha) == 1
                        expect(mediaControl.controlsWrapperView.alpha) == 1
                        expect(mediaControl.controlsHidden).to(beFalse())
                    }
                    
                    it("Should hide it's control after hide is called and media control is enabled") {
                        container.mediaControlEnabled = true
                        mediaControl.hide()
                        
                        expect(mediaControl.controlsOverlayView.alpha) == 0
                        expect(mediaControl.controlsWrapperView.alpha) == 0
                        expect(mediaControl.controlsHidden).to(beTrue())
                    }
                    
                    it("Should show it's control after show is called and media control is enabled") {
                        container.mediaControlEnabled = true
                        mediaControl.hide()
                        mediaControl.show()
                        
                        expect(mediaControl.controlsOverlayView.alpha) == 1
                        expect(mediaControl.controlsWrapperView.alpha) == 1
                        expect(mediaControl.controlsHidden).to(beFalse())
                    }
                }
                
                context("Play") {
                    
                    beforeEach() {
                        mediaControl.mediaControlButton.selected = false
                    }
                    
                    it("Should call container play when is paused") {
                        mediaControl.mediaControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(container.isPlaying).to(beTrue())
                    }
                    
                    it("Should change button state to selected") {
                        mediaControl.mediaControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(mediaControl.mediaControlButton.selected).to(beTrue())
                    }
                    
                    it("Should trigger playing event ") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.Playing.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.mediaControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Pause") {
                    beforeEach() {
                        mediaControl.mediaControlButton.selected = true
                    }
                    
                    it("Should call container pause when is playing") {
                        mediaControl.mediaControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(container.isPlaying).to(beFalse())
                    }
                    
                    it("Should change button state to not selected") {
                        mediaControl.mediaControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(mediaControl.mediaControlButton.selected).to(beFalse())
                    }
                    
                    it("Should trigger not playing event ") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.NotPlaying.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.mediaControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Current Time") {
                    it("Should start with 00:00 as current time") {
                        expect(mediaControl.currentTimeLabel.text) == "00:00"
                    }
                    
                    it ("Should listen to current time updates") {
                        let info: EventUserInfo = ["position" : 78]
                        playback.trigger(PlaybackEvent.TimeUpdated.rawValue, userInfo: info)
                        
                        expect(mediaControl.currentTimeLabel.text) == "01:18"
                    }
                }
                
                context("Duration") {
                    it("Should start with 00:00 as duration") {
                        expect(mediaControl.currentTimeLabel.text) == "00:00"
                    }
                    
                    it ("Should listen to Ready event ") {
                        playback.trigger(PlaybackEvent.Ready.rawValue)
                        
                        expect(mediaControl.durationLabel.text) == "00:30"
                    }
                }
                
                context("End") {
                    it("Should reset play button state after container end event") {
                        mediaControl.mediaControlButton.selected = true
                        container.trigger(ContainerEvent.Ended.rawValue)
                        
                        expect(mediaControl.mediaControlButton.selected).to(beFalse())
                    }
                }
            }
        }
    }
    
    class StubedPlayback: Playback {
        var playing = false
        
        override func isPlaying() -> Bool {
            return playing
        }
        
        override func play() {
            playing = true
        }
        
        override func pause() {
            playing = false
        }
        
        override func duration() -> Double {
            return 30
        }
    }
}