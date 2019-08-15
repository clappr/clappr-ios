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
                    expect(ClapprAnimationDuration.mediaControlShow).to(equal(0.3))
                }
            }

            describe("#secondsToHideControlFast") {
                it("is 0.4 seconds") {
                    expect(mediaControl.shortTimeToHideMediaControl).to(equal(0.4))
                }
            }

            describe("#secondsToHideControlSlow") {
                it("is 4 seconds") {
                    expect(mediaControl.longTimeToHideMediaControl).to(equal(4))
                }
            }

            describe("#view") {
                it("has 1 gesture recognizer") {
                    mediaControl.render()

                    expect(mediaControl.view.gestureRecognizers?.count).to(equal(1))
                }
            }

            describe("#tapped") {
                it("hides the mediacontrol and stop timer") {
                    mediaControl.render()

                    mediaControl.tapped()

                    expect(mediaControl.hideControlsTimer?.isValid).to(beNil())
                    expect(mediaControl.view.isHidden).to(beTrue())
                }

                context("when a option to keep media control always visible is given") {
                    it("doesn't hide the mediacontrol and stop timer") {
                        let options: Options = [kMediaControlAlwaysVisible: true]
                        let core = Core(options: options)
                        let mediaControl = MediaControl(context: core)
                        mediaControl.render()

                        mediaControl.tapped()

                        expect(mediaControl.hideControlsTimer?.isValid).to(beNil())
                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                    }
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
                it("has the same options as the Core") {
                    let options: Options = ["foo": "bar"]
                    let core = Core(options: options)

                    let mediaControl = MediaControl(context: core)

                    expect(mediaControl.options).toNot(beNil())
                    expect((mediaControl.options!["foo"] as! String)).to(equal("bar"))
                }
            }

            describe("Events") {
                beforeEach {
                    mediaControl.mediaControlShow = 0.1
                    mediaControl.mediaControlHide = 0.1
                    mediaControl.shortTimeToHideMediaControl = 0.1
                    mediaControl.longTimeToHideMediaControl = 0.1
                    mediaControl.render()
                }
                
                context("when ready") {
                    it("shows the media control") {
                        mediaControlHidden()

                        coreStub.activePlayback?.trigger(Event.ready)

                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }
                }

                context("when playing") {
                    it("shows the media control") {
                        mediaControlHidden()

                        coreStub.activePlayback?.trigger(Event.playing)

                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
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

                        expect(mediaControl.view.isHidden).to(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }
                }

                context("when showMediaControl") {
                    it("shows itself when hidden") {
                        mediaControlHidden()

                        coreStub.trigger(InternalEvent.didTappedCore.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                    }

                    it("doesn't show itself if an error occurred") {
                        mediaControlVisible()
                        mediaControlHidden()

                        coreStub.activePlayback?.trigger(Event.error.rawValue)
                        coreStub.trigger(InternalEvent.didTappedCore.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }
                }

                context("when paused") {
                    it("keeps itself on the screen and visible") {
                        mediaControlVisible()

                        coreStub.activePlayback?.trigger(Event.didPause)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when willBeginScrubbing") {
                    it("keeps itself on the screen and visible") {
                        mediaControlVisible()

                        coreStub.trigger(InternalEvent.willBeginScrubbing.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when didFinishScrubbing") {
                    it("hides the media control after some time if the video is playing") {
                        mediaControlVisible()

                        coreStub.trigger(InternalEvent.didFinishScrubbing.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }

                    it("doesn't hide the media control after some time if the video is paused") {
                        mediaControlVisible()
                        coreStub.activePlayback?.trigger(Event.didPause)

                        coreStub.trigger(InternalEvent.willBeginScrubbing.rawValue)
                        coreStub.trigger(InternalEvent.didFinishScrubbing.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())

                    }
                }
                context("when didEnterFullscreen") {
                    it("hides the media control after some time if the video is playing") {
                        mediaControlVisible()

                        coreStub.trigger(Event.didEnterFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }

                    it("doesn't hide the media control after some time if the video is paused") {
                        mediaControlVisible()
                        coreStub.activePlayback?.trigger(Event.didPause)

                        coreStub.trigger(Event.didEnterFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when didExitFullscreen") {
                    it("hides the media control after some time if the video is playing") {
                        mediaControlVisible()

                        coreStub.trigger(Event.didExitFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beTrue())
                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }

                    it("doesn't hide the media control after some time if the video is paused") {
                        mediaControlVisible()
                        coreStub.activePlayback?.trigger(Event.didPause)

                        coreStub.trigger(Event.didEnterFullscreen.rawValue)

                        expect(mediaControl.hideControlsTimer?.isValid).toEventually(beFalse())
                    }
                }

                context("when disableMediaControl") {
                    it("hides the media control immediately") {
                        mediaControlVisible()

                        coreStub.activeContainer?.trigger(Event.disableMediaControl.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beTrue())
                        expect(mediaControl.view.alpha).toEventually(equal(0))
                    }
                }

                context("when enableMediaControl") {
                    it("shows the media control") {
                        mediaControlHidden()

                        coreStub.activeContainer?.trigger(Event.enableMediaControl.rawValue)

                        expect(mediaControl.view.isHidden).toEventually(beFalse())
                        expect(mediaControl.view.alpha).toEventually(equal(1))
                    }
                }

                func mediaControlHidden() {
                    coreStub.activePlayback?.trigger(Event.didComplete)
                }

                func mediaControlVisible() {
                    coreStub.trigger(InternalEvent.didTappedCore.rawValue)
                }
            }
            
            describe("show") {
                it("triggers willShowMediaControl before showing the view") {
                    var eventTriggered = false
                    var viewIsVisible: Bool?
                    
                    mediaControl.render()
                    coreStub.on(Event.willShowMediaControl.rawValue) { _ in
                        eventTriggered = true
                        viewIsVisible = !mediaControl.view.isHidden
                    }
                    mediaControl.show()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(viewIsVisible).to(beFalse())
                }
                
                it("triggers didShowMediaControl after showing the view") {
                    var eventTriggered = false
                    var viewIsVisible: Bool?
                    mediaControl.view.isHidden = true
                    
                    coreStub.on(Event.didShowMediaControl.rawValue) { _ in
                        eventTriggered = true
                        viewIsVisible = !mediaControl.view.isHidden
                    }
                    mediaControl.show()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(viewIsVisible).to(beTrue())
                }
            }
            
            describe("hide") {
                it("triggers willHideMediaControl before hiding the view") {
                    var eventTriggered = false
                    var viewIsVisible: Bool?
                    
                    coreStub.on(Event.willHideMediaControl.rawValue) { _ in
                        eventTriggered = true
                        viewIsVisible = !mediaControl.view.isHidden
                    }
                    mediaControl.hide()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(viewIsVisible).to(beTrue())
                }
                
                it("triggers didHideMediaControl after showing the view") {
                    var eventTriggered = false
                    var viewIsVisible: Bool?
                    
                    coreStub.on(Event.didHideMediaControl.rawValue) { _ in
                        eventTriggered = true
                        viewIsVisible = !mediaControl.view.isHidden
                    }
                    mediaControl.hide()
                    
                    expect(eventTriggered).toEventually(beTrue())
                    expect(viewIsVisible).to(beFalse())
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
                    it("always calls the MediaControlView to position the view") {
                        let mediaControl = MediaControl(context: coreStub)
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()
                        
                        mediaControl.renderElements(elements)

                        expect(mediaControlViewMock.didCallAddSubview).to(beTrue())
                    }

                    it("always calls the MediaControlView passing the element's view") {
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()
                        
                        mediaControl.renderElements(elements)

                        expect(mediaControlViewMock.didCallAddSubviewWithView).to(equal(elements.first?.view))
                    }

                    it("always calls the MediaControlView passing the element's panel") {
                        MediaControlElementMock._panel = .center
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()
                        
                        mediaControl.renderElements(elements)

                        expect(mediaControlViewMock.didCallAddSubviewWithPanel).to(equal(MediaControlPanel.center))
                    }

                    it("always calls the MediaControlView passing the element's position") {
                        MediaControlElementMock._position = .left
                        mediaControl.mediaControlView = mediaControlViewMock
                        mediaControl.render()

                        mediaControl.renderElements(elements)
                        
                        expect(mediaControlViewMock.didCallAddSubviewWithPosition).to(equal(MediaControlPosition.left))
                    }

                    it("always calls the method render") {
                        MediaControlElementMock._panel = .top
                        mediaControl.render()
                        
                        mediaControl.renderElements(elements)

                        expect(MediaControlElementMock.didCallRender).to(beTrue())
                    }

                    it("protect the main thread when element crashes in render") {
                        MediaControlElementMock.crashOnRender = true
                        mediaControl.render()

                        mediaControl.renderElements(elements)

                        expect(mediaControl).to(beAKindOf(MediaControl.self))
                    }
                }

                context("when kMediaControlElementsOrder is passed") {
                    it("renders the elements following the kMediaControlElementsOrder with all elements specified in the option") {
                        let core = Core()
                        core.options[kMediaControlElementsOrder] = ["FullscreenButton", "TimeIndicatorElementMock", "SecondElement", "FirstElement"]
                        let elements = [FirstElement(context: core), SecondElement(context: core), TimeIndicatorElementMock(context: core), FullscreenButton(context: core), ]
                        let mediaControl = MediaControl(context: core)
                        mediaControl.render()

                        mediaControl.renderElements(elements)

                        let bottomRightView = mediaControl.mediaControlView.bottomRight
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

                        mediaControl.renderElements(elements)

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
