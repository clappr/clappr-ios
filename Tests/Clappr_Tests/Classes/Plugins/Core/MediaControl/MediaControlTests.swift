import Quick
import Nimble

@testable import Clappr

class MediaControlTests: QuickSpec {
    override func spec() {
        describe(".MediaControl") {
            describe("pluginName") {
                it("returns the pluginName") {
                    let mediaControl = MediaControl()

                    expect(mediaControl.pluginName).to(equal("MediaControl"))
                }
            }

            describe("#animationDuration") {
                it("is 0.3 seconds") {
                    let mediaControl = MediaControl()

                    expect(mediaControl.animationDuration).to(equal(0.3))
                }
            }

            describe("#secondsToHideControlFast") {
                it("is 0.4 seconds") {
                    let mediaControl = MediaControl()

                    expect(mediaControl.secondsToHideControlFast).to(equal(0.4))
                }
            }

            describe("#secondsToHideControlSlow") {
                it("is 4 seconds") {
                    let mediaControl = MediaControl()

                    expect(mediaControl.secondsToHideControlSlow).to(equal(4))
                }
            }

            describe("#view") {
                it("has 1 gesture recognizer") {
                    let coreStub = CoreStub()
                    let mediaControl = MediaControl(context: coreStub)

                    mediaControl.render()

                    expect(mediaControl.view.gestureRecognizers?.count).to(equal(1))
                }
            }

            describe("#tapped") {
                it("hides the mediacontrol and stop timer") {
                    let coreStub = CoreStub()
                    let mediaControl = MediaControl(context: coreStub)
                    mediaControl.render()

                    mediaControl.tapped()

                    expect(mediaControl.hideControlsTimer?.isValid).to(beNil())
                    expect(mediaControl.isHidden).to(beTrue())
                }

                context("when a option to keep media control always visible is given") {
                    it("doesn't hide the mediacontrol and stop timer") {
                        let options: Options = [kMediaControlAlwaysVisible: true]
                        let core = Core(loader: Loader(), options: options)
                        let mediaControl = MediaControl(context: core)
                        mediaControl.render()

                        mediaControl.tapped()

                        expect(mediaControl.hideControlsTimer?.isValid).to(beNil())
                        expect(mediaControl.isHidden).toEventually(beFalse())
                    }
                }
            }

            describe("#render") {
                var coreStub: CoreStub!

                beforeEach {
                    coreStub = CoreStub()
                }

                it("starts hidden") {
                    let mediaControl = MediaControl(context: coreStub)

                    mediaControl.render()

                    expect(mediaControl.isHidden).to(beTrue())
                }

                it("has black background with 60% of opacity") {
                    let mediaControl = MediaControl(context: coreStub)

                    mediaControl.render()

                    expect(mediaControl.view.backgroundColor).to(equal(UIColor.clapprBlack60Color()))
                }

                it("fills the superview") {
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let superview = UIView(frame: frame)
                    let mediaControl = MediaControl(context: coreStub)

                    superview.addSubview(mediaControl)
                    mediaControl.render()

                    expect(superview.constraints.count).to(equal(4))
                }

                it("inflates the MediaControl xib in the view") {
                    let mediaControl = MediaControl(context: coreStub)

                    mediaControl.render()

                    expect(mediaControl.container).to(beAKindOf(MediaControlView.self))
                    expect(mediaControl.view.subviews).to(contain(mediaControl.container))
                }
            }

            describe("options") {
                it("has the same options as the Core") {
                    let options: Options = ["foo": "bar"]
                    let core = Core(loader: Loader(), options: options)

                    let mediaControl = MediaControl(context: core)

                    expect(mediaControl.options).toNot(beNil())
                    expect((mediaControl.options!["foo"] as! String)).to(equal("bar"))
                }
            }

            describe("plugins") {
                it("has the list of plugins that comes from options") {
                    let options: Options = [kMediaControlPlugins: [MediaControlPluginMock.self]]
                    let core = Core(loader: Loader(), options: options)

                    let mediaControl = MediaControl(context: core)
                    mediaControl.defaultPlugins = []
                    mediaControl.render()

                    expect(mediaControl.plugins.count).to(equal(3))
                    expect(mediaControl.plugins[0]).to(beAKindOf(MediaControlPluginMock.self))
                }

                it("has the list of plugins that comes from options without default") {
                    let options: Options = [kMediaControlPlugins: [MediaControlPluginMock.self]]

                    let core = Core(loader: Loader(), options: options)

                    let mediaControl = MediaControl(context: core)
                    mediaControl.defaultPlugins = []
                    mediaControl.render()

                    expect(mediaControl.plugins.count).to(equal(1))
                    expect(mediaControl.plugins[0]).to(beAKindOf(MediaControlPluginMock.self))
                }
            }

            describe("Events") {
                var coreStub: CoreStub!
                var mediaControl: MediaControl!

                beforeEach {
                    coreStub = CoreStub()

                    mediaControl = MediaControl(context: coreStub)
                    mediaControl.animationDuration = 0.1
                    mediaControl.secondsToHideControlFast = 0.1
                    mediaControl.secondsToHideControlSlow = 0.1
                    mediaControl.render()
                }
                
                context("when ready") {
                    it("shows the media control") {
                        mediaControlHidden()

                        coreStub.activePlayback?.trigger(Event.ready)

                        expect(mediaControl.isHidden).toEventually(beFalse())
                        expect(mediaControl.alpha).toEventually(equal(1))
                    }
                }

                context("when playing") {
                    it("shows the media control") {
                        mediaControlHidden()

                        coreStub.activePlayback?.trigger(Event.playing)

                        expect(mediaControl.isHidden).toEventually(beFalse())
                        expect(mediaControl.alpha).toEventually(equal(1))
                    }

                    it("starts the timer to hide itself") {
                        mediaControlVisible()

                        coreStub.activePlayback?.trigger(Event.playing)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                    }
                }

                context("when complete") {
                    it("hides the media control") {
                        mediaControlVisible()

                        coreStub.activePlayback?.trigger(Event.didComplete)

                        expect(mediaControl.isHidden).to(beTrue())
                        expect(mediaControl.alpha).toEventually(equal(0))
                    }
                }

                context("when showMediaControl") {
                    it("shows itself when hidden") {
                        mediaControlHidden()

                        coreStub.trigger(Event.willShowMediaControl.rawValue)

                        expect(mediaControl.isHidden).to(beFalse())
                        expect(mediaControl.alpha).to(equal(1))
                    }

                    it("doesn't show itself if an error occurred") {
                        mediaControlHidden()

                        coreStub.activePlayback?.trigger(Event.error.rawValue)
                        coreStub.trigger(Event.willShowMediaControl.rawValue)

                        expect(mediaControl.isHidden).to(beTrue())
                        expect(mediaControl.alpha).to(equal(0))
                    }
                }

                context("when paused") {
                    it("keeps itself on the screen and visible") {
                        mediaControlVisible()

                        coreStub.activePlayback?.trigger(Event.didPause)

                        expect(mediaControl.isHidden).toEventually(beFalse())
                        expect(mediaControl.alpha).toEventually(equal(1))
                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when didEnterFullscreen") {
                    it("hides the media control after some time if the video is playing") {
                        mediaControlVisible()

                        coreStub.trigger(InternalEvent.didEnterFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                        expect(mediaControl.isHidden).toEventually(beTrue())
                        expect(mediaControl.alpha).toEventually(equal(0))
                    }

                    it("doesn't hide the media control after some time if the video is paused") {
                        mediaControlVisible()
                        coreStub.activePlayback?.trigger(Event.didPause)

                        coreStub.trigger(InternalEvent.didEnterFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when didExitFullscreen") {
                    it("hides the media control after some time if the video is playing") {
                        mediaControlVisible()

                        coreStub.trigger(InternalEvent.didExitFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                        expect(mediaControl.isHidden).toEventually(beTrue())
                        expect(mediaControl.alpha).toEventually(equal(0))
                    }

                    it("doesn't hide the media control after some time if the video is paused") {
                        mediaControlVisible()
                        coreStub.activePlayback?.trigger(Event.didPause)

                        coreStub.trigger(InternalEvent.didEnterFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when disableMediaControl") {
                    it("hides the media control immediately") {
                        mediaControlVisible()

                        coreStub.activeContainer?.trigger(Event.disableMediaControl.rawValue)

                        expect(mediaControl.isHidden).toEventually(beTrue())
                        expect(mediaControl.alpha).toEventually(equal(0))
                    }
                }

                context("when enableMediaControl") {
                    it("shows the media control") {
                        mediaControlHidden()

                        coreStub.activeContainer?.trigger(Event.enableMediaControl.rawValue)

                        expect(mediaControl.isHidden).toEventually(beFalse())
                        expect(mediaControl.alpha).toEventually(equal(1))
                    }
                }

                func mediaControlHidden() {
                    coreStub.activePlayback?.trigger(Event.didComplete)
                }

                func mediaControlVisible() {
                    coreStub.trigger(Event.willShowMediaControl.rawValue)
                }
            }

            describe("renderPlugins") {
                var options: Options!
                var core: Core!
                var mediaControlViewMock: MediaControlViewMock!

                beforeEach {
                    options = [kMediaControlPlugins: [MediaControlPluginMock.self]]

                    core = Core(loader: Loader(), options: options)
                    mediaControlViewMock = MediaControlViewMock()
                    MediaControlPluginMock.reset()
                }

                context("for any plugin configuration") {
                    it("always calls the MediaControlView to position the view") {
                        let mediaControl = MediaControl(context: core)
                        mediaControl.container = mediaControlViewMock
                        mediaControl.defaultPlugins = []
                        mediaControl.render()

                        expect(mediaControlViewMock.didCallAddSubview).to(beTrue())
                    }

                    it("always calls the MediaControlView passing the plugin's view") {
                        let mediaControl = MediaControl(context: core)
                        mediaControl.container = mediaControlViewMock
                        mediaControl.defaultPlugins = []
                        mediaControl.render()

                        if let plugin = mediaControl.plugins.first(where: {$0.pluginName == "MediaControlPluginMock" }) {
                            expect(mediaControlViewMock.didCallAddSubviewWithView).to(equal(plugin.view))
                        } else {
                            fail()
                        }
                    }

                    it("always calls the MediaControlView passing the plugin's panel") {
                        MediaControlPluginMock._panel = .center
                        let mediaControl = MediaControl(context: core)
                        mediaControl.container = mediaControlViewMock
                        mediaControl.defaultPlugins = []
                        mediaControl.render()

                        expect(mediaControlViewMock.didCallAddSubviewWithPanel).to(equal(MediaControlPanel.center))
                    }

                    it("always calls the MediaControlView passing the plugin's position") {
                        MediaControlPluginMock._position = .left
                        let mediaControl = MediaControl(context: core)
                        mediaControl.container = mediaControlViewMock
                        mediaControl.defaultPlugins = []
                        mediaControl.render()

                        expect(mediaControlViewMock.didCallAddSubviewWithPosition).to(equal(MediaControlPosition.left))
                    }

                    it("always calls the method render") {
                        MediaControlPluginMock._panel = .top
                        let mediaControl = MediaControl(context: core)

                        mediaControl.render()

                        expect(MediaControlPluginMock.didCallRender).to(beTrue())
                    }
                }
            }

            class MediaControlPluginMock: MediaControlPlugin {
                static var _panel: MediaControlPanel = .top
                static var _position: MediaControlPosition = .left
                static var didCallRender = false

                override var pluginName: String {
                    return "MediaControlPluginMock"
                }

                open override var panel: MediaControlPanel {
                    return MediaControlPluginMock._panel
                }

                open override var position: MediaControlPosition {
                    return MediaControlPluginMock._position
                }

                override func render() {
                    MediaControlPluginMock.didCallRender = true
                }

                static func reset() {
                    MediaControlPluginMock.didCallRender = false
                }
            }

            class MediaControlViewMock: MediaControlView {
                var didCallAddSubview = false
                var didCallAddSubviewWithView: UIView?
                var didCallAddSubviewWithPanel: MediaControlPanel?
                var didCallAddSubviewWithPosition: MediaControlPosition?

                override func addSubview(_ view: UIView, panel: MediaControlPanel, position: MediaControlPosition) {
                    didCallAddSubviewWithView = view
                    didCallAddSubviewWithPanel = panel
                    didCallAddSubviewWithPosition = position
                    didCallAddSubview = true
                }
            }
        }
    }
}
