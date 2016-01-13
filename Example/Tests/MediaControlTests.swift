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
                    it("Should call container play when is paused") {
                        mediaControl.playbackControlState = .Paused
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(container.isPlaying).to(beTrue())
                    }
                    
                    it("Should call container play when is stopped") {
                        mediaControl.playbackControlState = .Stopped
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(container.isPlaying).to(beTrue())
                    }
                    
                    it("Should trigger playing event ") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.Playing.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Pause") {
                    beforeEach() {
                        mediaControl.playbackControlState = .Playing
                        playback.playbackType = .VOD
                    }
                    
                    it("Should call container pause when is playing") {
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(container.isPlaying).to(beFalse())
                    }
                    
                    it("Should change playback control state to paused") {
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(mediaControl.playbackControlState) == PlaybackControlState.Paused
                    }
                    
                    it("Should trigger not playing event when selecting button") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.NotPlaying.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Stop") {
                    beforeEach() {
                        mediaControl.playbackControlState = .Playing
                        playback.playbackType = .Live
                        container.trigger(ContainerEvent.Ready.rawValue)
                    }
                    
                    it("Should call container pause when is live video is playing") {
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(container.isPlaying).to(beFalse())
                    }
                    
                    it("Should change playback control state to stopped") {
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(mediaControl.playbackControlState) == PlaybackControlState.Stopped
                    }
                    
                    it("Should trigger not playing event when selecting button") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.NotPlaying.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.playbackControlButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        
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
                        mediaControl.playbackControlState = .Playing
                        container.trigger(ContainerEvent.Ended.rawValue)
                        
                        expect(mediaControl.playbackControlState) == PlaybackControlState.Stopped
                    }
                }
            }
        }
    }
    
    class StubedPlayback: Playback {
        var playing = false
        var playbackType = PlaybackType.VOD
        
        override func isPlaying() -> Bool {
            return playing
        }
        
        override func play() {
            playing = true
        }
        
        override func pause() {
            playing = false
        }
        
        override func type() -> PlaybackType {
            return playbackType
        }
        
        override func duration() -> Double {
            return 30
        }
    }
}