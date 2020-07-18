import Quick
import Nimble

@testable import Clappr

class MediaControlTests: QuickSpec {
    override func spec() {
        describe(".MediaControl") {
            var coreStub: CoreStub!
            var mediaControl: MediaControl!

            beforeEach {
                coreStub = CoreStub()
                mediaControl = MediaControl(context: coreStub)
            }

            describe("pluginName") {
                it("returns the pluginName") {
                    expect(mediaControl.pluginName).to(equal("MediaControl"))
                }
            }

            describe("#animationDuration") {
                it("is 0.3 seconds") {
                    expect(ClapprAnimationDuration.mediaControlHide).to(equal(0.3))
                    expect(ClapprAnimationDuration.mediaControlShow).to(equal(0.3))
                }
            }

            describe("#shortTimeToHideMediaControl") {
                it("is 0.3 seconds") {
                    expect(mediaControl.shortTimeToHideMediaControl).to(equal(0.3))
                }
            }

            describe("#longTimeToHideMediaControl") {
                it("is 3 seconds") {
                    expect(mediaControl.longTimeToHideMediaControl).to(equal(3))
                }
            }

            describe("#view") {
                it("has 1 gesture recognizer") {
                    mediaControl.render()

                    expect(mediaControl.view.gestureRecognizers?.count).to(equal(1))
                }
            }

            describe("#hideAndStopTimer") {
                it("hides the mediacontrol and stop timer") {
                    mediaControl.render()

                    mediaControl.hideAndStopTimer()

                    expect(mediaControl.hideControlsTimer?.isValid).to(beNil())
                    expect(mediaControl.view.isHidden).to(beTrue())
                }
            }

            describe("#render") {
                it("starts hidden") {
                    mediaControl.render()

                    expect(mediaControl.view.isHidden).to(beTrue())
                }

                it("has clear background") {
                    mediaControl.render()

                    expect(mediaControl.view.backgroundColor).to(equal(UIColor.clear))
                }

                it("has constrastView with black background with 60% of opacity") {
                    mediaControl.render()

                    expect(mediaControl.mediaControlView.contrastView.backgroundColor).to(equal(UIColor.clapprBlack60Color()))
                }
                
                it("fills the superview") {
                    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    let superview = UIView(frame: frame)
                    superview.addSubview(mediaControl.view)

                    mediaControl.render()

                    expect(superview.constraints.count).to(equal(4))
                }

                it("inflates the MediaControl xib in the view") {
                    mediaControl.render()

                    expect(mediaControl.mediaControlView).to(beAKindOf(MediaControlView.self))
                    expect(mediaControl.view.subviews).to(contain(mediaControl.mediaControlView))
                }
            }

            describe("options") {
                context("when kMediaControlAlwaysVisible is true") {
                    it("keeps itself visible without timer") {
                        let options: Options = [kMediaControlAlwaysVisible: true]
                        coreStub.options = options
                        let mediaControl = MediaControl(context: coreStub)
                        mediaControl.render()

                        coreStub.activePlayback?.trigger(.playing)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beNil())
                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                    }
                }

                it("has the same options as the Core") {
                    let options: Options = ["foo": "bar"]
                    coreStub.options = options

                    let mediaControl = MediaControl(context: coreStub)

                    expect(mediaControl.options).toNot(beNil())
                    expect(mediaControl.options?["foo"] as? String).to(equal("bar"))
                }
            }

            describe("Events") {
                beforeEach {
                    mediaControl.showDuration = 0.1
                    mediaControl.hideDuration = 0.1
                    mediaControl.shortTimeToHideMediaControl = 0.1
                    mediaControl.longTimeToHideMediaControl = 0.1
                    mediaControl.render()
                }
                
                context("requestPadding") {
                    it("applies padding") {
                        mediaControl.render()

                        coreStub.trigger(.requestPadding, userInfo: ["padding": CGFloat(32)])

                        expect(mediaControl.mediaControlView.bottomPadding?.constant).toEventually(equal(32.0))
                    }
                }

                context("playing") {
                    context("after a pause") {
                        it("hides itself after some time and stop timer") {
                            showMediaControl()
                            coreStub.activePlayback?.trigger(.didPause)
                            
                            coreStub.activePlayback?.trigger(.playing)
                            
                            expect(mediaControl.view.isHidden).toEventually(beTrue())
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("after a complete") {
                        it("hides itself after some time and stop timer") {
                            showMediaControl()
                            coreStub.activePlayback?.trigger(.didComplete)
                            
                            coreStub.activePlayback?.trigger(.playing)
                            
                            expect(mediaControl.view.isHidden).toEventually(beTrue())
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                }

                context("didComplete") {
                    it("shows itself") {
                        hideMediaControl()

                        coreStub.activePlayback?.trigger(.didComplete)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                    }
                }

                context("didTappedCore") {
                    it("shows itself and start the timer to hide") {
                        hideMediaControl()

                        coreStub.trigger(InternalEvent.didTappedCore.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                    }
                }

                context("didPause") {
                    it("keeps itself on the screen and visible") {
                        mediaControl.hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in return })
                        showMediaControl()

                        coreStub.activePlayback?.trigger(.didPause)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("willBeginScrubbing") {
                    it("keeps itself on the screen and visible") {
                        mediaControl.hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in return })
                        showMediaControl()

                        coreStub.trigger(InternalEvent.willBeginScrubbing.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("didFinishScrubbing") {
                    beforeEach {
                        mediaControl.hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in return })
                        showMediaControl()
                    }
                    
                    context("and the playback is playing") {
                        it("hides itself after some time") {
                            coreStub.playbackMock?.set(state: .playing)
                            
                            coreStub.trigger(InternalEvent.didFinishScrubbing.rawValue)

                            expect(mediaControl.view.isHidden).toEventually(beTrue())
                            expect(mediaControl.view.alpha).toEventually(equal(0))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is paused") {
                        it("keeps itself on the screen and visible") {
                            coreStub.playbackMock?.set(state: .paused)
                            coreStub.activePlayback?.trigger(.didPause)

                            coreStub.trigger(InternalEvent.didFinishScrubbing.rawValue)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is idle") {
                        it("keeps itself on the screen and visible") {
                            coreStub.playbackMock?.set(state: .idle)
                            coreStub.activePlayback?.trigger(.didComplete)

                            coreStub.trigger(InternalEvent.didFinishScrubbing.rawValue)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())

                        }
                    }
                }
                context("didEnterFullscreen") {
                    beforeEach {
                        mediaControl.hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in return })
                        showMediaControl()
                    }
                    
                    context("and the playback is playing") {
                        it("hides itself after some time") {
                            coreStub.playbackMock?.set(state: .playing)
                            
                            coreStub.trigger(.didEnterFullscreen)

                            expect(mediaControl.view.isHidden).toEventually(beTrue())
                            expect(mediaControl.view.alpha).toEventually(equal(0))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is paused") {
                        it("keeps itself on the screen and visible") {
                            coreStub.playbackMock?.set(state: .paused)
                            coreStub.activePlayback?.trigger(.didPause)

                            coreStub.trigger(.didEnterFullscreen)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is idle") {
                        it("keeps itself on the screen and visible") {
                            coreStub.playbackMock?.set(state: .idle)
                            coreStub.activePlayback?.trigger(.didComplete)

                            coreStub.trigger(.didEnterFullscreen)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())

                        }
                    }
                }

                context("didExitFullscreen") {
                    beforeEach {
                        mediaControl.hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in return })
                        showMediaControl()
                    }
                    
                    context("and the playback is playing") {
                        it("hides itself after some time") {
                            coreStub.playbackMock?.set(state: .playing)
                            
                            coreStub.trigger(.didExitFullscreen)

                            expect(mediaControl.view.isHidden).toEventually(beTrue())
                            expect(mediaControl.view.alpha).toEventually(equal(0))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is paused") {
                        it("keeps itself visible") {
                            coreStub.playbackMock?.set(state: .paused)
                            coreStub.activePlayback?.trigger(.didPause)

                            coreStub.trigger(.didExitFullscreen)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is idle") {
                        it("keeps itself on the screen and visible") {
                            coreStub.playbackMock?.set(state: .idle)
                            coreStub.activePlayback?.trigger(.didComplete)

                            coreStub.trigger(.didExitFullscreen)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())

                        }
                    }
                }

                context("disableMediaControl") {
                    it("hides itself immediately") {
                        showMediaControl()

                        coreStub.activeContainer?.trigger(.disableMediaControl)

                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }
                }

                context("enableMediaControl") {
                    it("shows itself immediately") {
                        hideMediaControl()

                        coreStub.activeContainer?.trigger(.enableMediaControl)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                    }
                }
                
                context("didDragDrawer") {
                    it("changes its alpha") {
                        showMediaControl()
                        var info = ["alpha":CGFloat(0.5)]
                        
                        coreStub.trigger(InternalEvent.didDragDrawer.rawValue, userInfo: info)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(0.5))
                    }
                }
                
                context("didShowDrawerPlugin") {
                    it("hides itself") {
                        showMediaControl()
                        
                        coreStub.trigger(.didShowDrawerPlugin)
                        
                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }
                }
                
                context("didHideDrawerPlugin") {
                    beforeEach {
                        mediaControl.hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in return })
                        showMediaControl()
                    }
                    
                    context("and the playback is playing") {
                        it("shows itself and starts the timer to hide") {
                            coreStub.playbackMock?.set(state: .playing)
                            
                            coreStub.trigger(.didHideDrawerPlugin)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                        }
                    }
                    
                    context("and the playback is paused") {
                        it("shows itself and keeps visible") {
                            coreStub.playbackMock?.set(state: .paused)

                            coreStub.trigger(.didHideDrawerPlugin)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                        }
                    }
                    
                    context("and the playback is idle") {
                        it("shows itself and keeps visible") {
                            coreStub.playbackMock?.set(state: .idle)

                            coreStub.trigger(.didHideDrawerPlugin)

                            expect(mediaControl.view.isHidden).toEventually(beFalse())
                            expect(mediaControl.view.alpha).toEventually(equal(1))
                            expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())

                        }
                    }

                }

                func hideMediaControl() {
                    mediaControl.view.isHidden = true
                    mediaControl.view.alpha = 0
                }

                func showMediaControl() {
                    mediaControl.view.isHidden = false
                    mediaControl.view.alpha = 1
                }
            }
            
            describe("show") {
                it("triggers willShowMediaControl before showing the view") {
                    var eventTriggered = false
                    var viewWasVisible = false
                    mediaControl.render()
                    
                    coreStub.on(Event.willShowMediaControl.rawValue) { _ in
                        eventTriggered = true
                        viewWasVisible = !mediaControl.view.isHidden
                    }
                    mediaControl.show()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(viewWasVisible).to(beFalse())
                }
                
                it("triggers didShowMediaControl after showing the view") {
                    var eventTriggered = false
                    mediaControl.view.isHidden = true
                    
                    coreStub.on(Event.didShowMediaControl.rawValue) { _ in
                        eventTriggered = true
                    }
                    mediaControl.show()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(mediaControl.view.isHidden).to(beFalse())
                }
            }
            
            describe("hide") {
                it("triggers willHideMediaControl before hiding the view") {
                    var eventTriggered = false
                    var viewWasVisible = false
                    mediaControl.view.isHidden = false
                    
                    coreStub.on(Event.willHideMediaControl.rawValue) { _ in
                        eventTriggered = true
                        viewWasVisible = !mediaControl.view.isHidden
                    }
                    mediaControl.hide()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(viewWasVisible).to(beTrue())
                }
                
                it("triggers didHideMediaControl after showing the view") {
                    var eventTriggered = false
                    
                    coreStub.on(Event.didHideMediaControl.rawValue) { _ in
                        eventTriggered = true
                    }
                    mediaControl.hide()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(mediaControl.view.isHidden).to(beTrue())
                }
            }

            describe("renderElements") {
                var elements: [MediaControl.Element]!
                var mediaControlViewMock: MediaControlViewMock!

                beforeEach {
                    elements = [MediaControlElementMock(context: coreStub)]
                    mediaControlViewMock = MediaControlViewMock()
                    MediaControlElementMock.reset()
                }

                context("for any element configuration") {
                    it("adds the element view as subview of MediaControlView") {
                        let mediaControl = MediaControl(context: coreStub)
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()
                        
                        mediaControl.render(elements)

                        expect(mediaControlViewMock.didCallAddSubview).to(beTrue())
                    }

                    it("passes the element's view") {
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()
                        
                        mediaControl.render(elements)
                        
                        expect(mediaControlViewMock.didCallAddSubviewWithView).to(equal(elements.first?.view))
                    }

                    it("passes the element's panel") {
                        MediaControlElementMock._panel = .center
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()
                         
                        mediaControl.render(elements)

                        expect(mediaControlViewMock.didCallAddSubviewWithPanel).to(equal(MediaControlPanel.center))
                    }

                    it("passes the element's position") {
                        MediaControlElementMock._position = .left
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()

                        mediaControl.render(elements)
                        
                        expect(mediaControlViewMock.didCallAddSubviewWithPosition).to(equal(MediaControlPosition.left))
                    }

                    it("calls the element's render method") {
                        MediaControlElementMock._panel = .top
                        mediaControl.render()
                        
                        mediaControl.render(elements)

                        expect(MediaControlElementMock.didCallRender).to(beTrue())
                    }

                    it("protects the main thread when element crashes in render") {
                        MediaControlElementMock.crashOnRender = true
                        mediaControl.render()

                        mediaControl.render(elements)

                        expect(mediaControl).to(beAKindOf(MediaControl.self))
                    }
                }

                context("when kMediaControlElementsOrder is passed") {
                    it("renders the elements following the kMediaControlElementsOrder with all elements specified in the option") {
                        let core = Core()
                        core.options[kMediaControlElementsOrder] = ["FullscreenButton", "TimeIndicatorElementMock", "SecondElement", "FirstElement"]
                        let elements = [FirstElement(context: core), SecondElement(context: core), TimeIndicatorElementMock(context: core), FullscreenButton(context: core)]
                        let mediaControl = MediaControl(context: core)
                        mediaControl.render()
                        let bottomRightView = mediaControl.mediaControlView.bottomRight
                        
                        mediaControl.render(elements)
                        
                        expect(bottomRightView?.subviews[0].subviews.first?.accessibilityIdentifier).to(equal("FullscreenButton"))
                        expect(bottomRightView?.subviews[1].subviews.first?.accessibilityIdentifier).to(equal("timeIndicator"))
                        expect(bottomRightView?.subviews[2].subviews.first?.accessibilityIdentifier).to(equal("SecondElement"))
                        expect(bottomRightView?.subviews[3].subviews.first?.accessibilityIdentifier).to(equal("FirstElement"))
                    }

                    it("renders the elements following the kMediaControlElementsOrder with only two elements specified in the option") {
                        let core = Core()
                        core.options[kMediaControlElementsOrder] = ["FullscreenButton", "TimeIndicatorElementMock"]
                        let elements = [FirstElement(context: core), SecondElement(context: core), TimeIndicatorElementMock(context: core), FullscreenButton(context: core), ]
                        let mediaControl = MediaControl(context: core)
                        mediaControl.render()

                        mediaControl.render(elements)

                        let bottomRightView = mediaControl.mediaControlView.bottomRight
                        expect(bottomRightView?.subviews[0].subviews.first?.accessibilityIdentifier).to(equal("FullscreenButton"))
                        expect(bottomRightView?.subviews[1].subviews.first?.accessibilityIdentifier).to(equal("timeIndicator"))
                        expect(bottomRightView?.subviews[2].subviews.first?.accessibilityIdentifier).to(equal("FirstElement"))
                        expect(bottomRightView?.subviews[3].subviews.first?.accessibilityIdentifier).to(equal("SecondElement"))
                    }
                }
            }

            class MediaControlViewMock: MediaControlView {
                var didCallAddSubview = false
                var didCallAddSubviewWithView: UIView?
                var didCallAddSubviewWithPanel: MediaControlPanel?
                var didCallAddSubviewWithPosition: MediaControlPosition?

                override func addSubview(_ view: UIView, in panel: MediaControlPanel, at position: MediaControlPosition) {
                    didCallAddSubviewWithView = view
                    didCallAddSubviewWithPanel = panel
                    didCallAddSubviewWithPosition = position
                    didCallAddSubview = true
                }
            }
        }
    }
}

class MediaControlElementMock: MediaControl.Element {
    static var _panel: MediaControlPanel = .top
    static var _position: MediaControlPosition = .left
    static var didCallRender = false
    static var crashOnRender = false
    
    override class var name: String {
        return "MediaControlElementMock"
    }
    
    open override var panel: MediaControlPanel {
        return MediaControlElementMock._panel
    }
    
    open override var position: MediaControlPosition {
        return MediaControlElementMock._position
    }

    override func bindEvents() { }

    override func render() {
        MediaControlElementMock.didCallRender = true

        if MediaControlElementMock.crashOnRender {
            codeThatCrashes()
        }

        trigger("render")
    }
    
    static func reset() {
        MediaControlElementMock.didCallRender = false
    }

    private func codeThatCrashes() {
        NSException(name:NSExceptionName(rawValue: "TestError"), reason:"Test Error", userInfo:nil).raise()
    }
}

class TimeIndicatorElementMock: TimeIndicator {
    override class var name: String {
        return "TimeIndicatorElementMock"
    }

    open override var panel: MediaControlPanel {
        return .bottom
    }

    open override var position: MediaControlPosition {
        return .right
    }

}

class FirstElement: MediaControl.Element {
    override class var name: String {
        return "FirstElement"
    }
    
    var button: UIButton! {
        didSet {
            button.accessibilityIdentifier = pluginName
            view.addSubview(button)
        }
    }

    override func bindEvents() { }

    override open func render() {
        button = UIButton(type: .custom)
    }

    open override var panel: MediaControlPanel {
        return .bottom
    }

    open override var position: MediaControlPosition {
        return .right
    }
}

class SecondElement: MediaControl.Element {
    override class var name: String {
        return "SecondElement"
    }

    var button: UIButton! {
        didSet {
            button.accessibilityIdentifier = pluginName
            view.addSubview(button)
        }
    }

    override func bindEvents() { }

    override open func render() {
        button = UIButton(type: .custom)
    }

    open override var panel: MediaControlPanel {
        return .bottom
    }

    open override var position: MediaControlPosition {
        return .right
    }
}
