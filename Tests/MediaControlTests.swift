import Quick
import Nimble
import Clappr

class MediaControlTests: QuickSpec {
    #if os(iOS)
    override func spec() {
        describe("MediaControl") {
            let options = [kSourceUrl: "http://globo.com/video.mp4"]
            var container: Container!
            var playback: StubedPlayback!

            beforeEach {
                let loader = Loader()
                loader.addExternalPlugins([StubedPlayback.self])
                container = Container(loader: loader, options: options as Options)
                playback = container.playback as! StubedPlayback
            }

            context("Initialization") {

                it("Should have a init method to setup with container") {
                    let mediaControl = MediaControl.create()
                    mediaControl.setup(container)

                    expect(mediaControl).toNot(beNil())
                    expect(mediaControl.container) == container
                }
            }

            context("Behavior") {
                var mediaControl: MediaControl!

                beforeEach {
                    mediaControl = MediaControl.create()
                    mediaControl.setup(container)
                }

                context("Visibility") {
                    it("Should start with controls hidden") {
                        expect(mediaControl.controlsOverlayView!.alpha) == 0
                        expect(mediaControl.controlsWrapperView!.alpha) == 0
                        expect(mediaControl.controlsHidden).to(beTrue())
                    }

                    it("Should show it's control after when media control is enabled on container") {
                        container.mediaControlEnabled = true

                        expect(mediaControl.controlsOverlayView!.alpha) == 1
                        expect(mediaControl.controlsWrapperView!.alpha) == 1
                        expect(mediaControl.controlsHidden).to(beFalse())
                    }

                    it("Should hide it's control after hide is called and media control is enabled") {
                        container.mediaControlEnabled = true
                        mediaControl.hide()

                        expect(mediaControl.controlsOverlayView!.alpha) == 0
                        expect(mediaControl.controlsWrapperView!.alpha) == 0
                        expect(mediaControl.controlsHidden).to(beTrue())
                    }

                    it("Should show it's control after show is called and media control is enabled") {
                        container.mediaControlEnabled = true
                        mediaControl.hide()
                        mediaControl.show()

                        expect(mediaControl.controlsOverlayView!.alpha) == 1
                        expect(mediaControl.controlsWrapperView!.alpha) == 1
                        expect(mediaControl.controlsHidden).to(beFalse())
                    }
                }

                context("Play") {
                    it("Should call container play when is paused") {
                        mediaControl.playbackControlState = .paused
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.playback?.isPlaying).to(beTrue())
                    }

                    it("Should call container play when is stopped") {
                        mediaControl.playbackControlState = .stopped
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.playback?.isPlaying).to(beTrue())
                    }

                    it("Should trigger playing event ") {
                        var callbackWasCalled = false
                        mediaControl.once(Event.playing.rawValue) { _ in
                            callbackWasCalled = true
                        }

                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)

                        expect(callbackWasCalled).to(beTrue())
                    }
                }

                context("Pause") {
                    beforeEach {
                        mediaControl.playbackControlState = .playing
                        playback.type = .vod
                    }

                    it("Should call container pause when is playing") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.playback?.isPlaying).to(beFalse())
                    }

                    it("Should change playback control state to paused") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(mediaControl.playbackControlState) == PlaybackControlState.paused
                    }

                    it("Should trigger didPause event when selecting button") {
                        var callbackWasCalled = false
                        mediaControl.once(Event.didPause.rawValue) { _ in
                            callbackWasCalled = true
                        }

                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)

                        expect(callbackWasCalled).to(beTrue())
                    }
                }

                context("Stop") {
                    beforeEach {
                        mediaControl.playbackControlState = .playing
                        playback.type = .live
                        playback.trigger(Event.ready.rawValue)
                    }

                    it("Should call container pause when is live video is playing") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.playback?.isPlaying).to(beFalse())
                    }

                    it("Should change playback control state to stopped") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(mediaControl.playbackControlState) == PlaybackControlState.stopped
                    }

                    it("Should trigger didStop event when selecting button") {
                        var callbackWasCalled = false
                        mediaControl.once(Event.didStop.rawValue) { _ in
                            callbackWasCalled = true
                        }

                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)

                        expect(callbackWasCalled).to(beTrue())
                    }
                }

                context("Current Time") {
                    it("Should start with 00:00 as current time") {
                        expect(mediaControl.currentTimeLabel!.text) == "00:00"
                    }

                    it("Should listen to current time updates") {
                        let info: EventUserInfo = ["position": 78.0]
                        playback.trigger(.positionUpdate, userInfo: info)

                        expect(mediaControl.currentTimeLabel!.text) == "01:18"
                    }
                }

                context("Duration") {
                    it("Should start with 00:00 as duration") {
                        expect(mediaControl.currentTimeLabel!.text) == "00:00"
                    }

                    it("Should listen to Ready event ") {
                        playback.trigger(.ready)

                        expect(mediaControl.durationLabel!.text) == "00:30"
                    }
                }

                context("End") {
                    it("Should reset play button state after container end event") {
                        mediaControl.playbackControlState = .playing
                        container.playback?.trigger(Event.didComplete.rawValue)

                        expect(mediaControl.playbackControlState) == PlaybackControlState.stopped
                    }
                }

                context("Fullscreen") {
                    it("Should hide fullscreen button if disabled via options") {
                        let options = [kFullscreenDisabled: true] as Options

                        container = Container(options: options)
                        mediaControl.setup(container)

                        expect(mediaControl.fullscreenButton?.isHidden) == true
                    }

                    it("Should show fullscreen button if no option is set") {
                        expect(mediaControl.fullscreenButton?.isHidden) == false
                    }
                }
            }
        }
    }

    class StubedPlayback: Playback {
        var playing = false
        var type = PlaybackType.vod

        override var pluginName: String {
            return "Playback"
        }

        override var isPlaying: Bool {
            return playing
        }

        override class func canPlay(_: Options) -> Bool {
            return true
        }

        override func play() {
            playing = true
        }

        override func pause() {
            playing = false
        }

        override var playbackType: PlaybackType {
            return type
        }

        override var duration: Double {
            return 30
        }
    }
    #endif
}
