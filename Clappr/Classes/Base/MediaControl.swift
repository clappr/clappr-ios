import Foundation

import MediaPlayer

public class MediaControl: UIBaseObject {
    private let animationDuration = 0.3
    
    @IBOutlet public var seekBarView: UIView?
    @IBOutlet public var bufferBarView: UIView?
    @IBOutlet public var progressBarView: UIView?
    @IBOutlet public var scrubberTimeView: UIView?
    @IBOutlet public var scrubberLabel: UILabel?
    @IBOutlet public var scrubberView: UIView?
    @IBOutlet public var scrubberOuterCircle: UIView?

    @IBOutlet public var scrubberOuterCircleWidthConstraint: NSLayoutConstraint?
    @IBOutlet public var scrubberOuterCircleHeightConstraint: NSLayoutConstraint?
    @IBOutlet public var bufferBarWidthConstraint: NSLayoutConstraint?
    @IBOutlet public var progressBarWidthConstraint: NSLayoutConstraint?

    @IBOutlet public var durationLabel: UILabel?
    @IBOutlet public var currentTimeLabel: UILabel?

    @IBOutlet public var backgroundOverlayView: UIView?

    @IBOutlet public var controlsOverlayView: UIView?
    @IBOutlet public var controlsWrapperView: UIView?
    @IBOutlet public var playbackControlButton: UIButton?
    @IBOutlet public var fullscreenButton: UIButton?

    @IBOutlet public weak var airPlayVolumeView: MPVolumeView?
    
    public internal(set) var container: Container!
    public internal(set) var controlsHidden = false
    
    public var bufferPercentage: CGFloat = 0.0
    public var seekPercentage: CGFloat = 0.0
    public var scrubberInitialPosition: CGFloat = 0.0
    public var scrubberInitialWidth: CGFloat = 0.0
    public var scrubberInitialHeight: CGFloat = 0.0
    public var hideControlsTimer: NSTimer?
    public var enabled = false
    public var livePlayback = false
    
    public lazy var liveProgressBarColor = UIColor.redColor()
    public lazy var vodProgressBarColor = UIColor.blueColor()
    public lazy var backgroundOverlayColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    public lazy var playButtonImage: UIImage? = self.imageFromName("play")
    public lazy var pauseButtonImage: UIImage? = self.imageFromName("pause")
    public lazy var stopButtonImage: UIImage? = self.imageFromName("stop")
    
    public var playbackControlState: PlaybackControlState = .Stopped {
        didSet {
            updatePlaybackControlButtonIcon()
        }
    }
    
    public var isSeeking = false {
        didSet {
            scrubberTimeView?.hidden = !isSeeking
            scrubberOuterCircleHeightConstraint?.constant = isSeeking ? scrubberInitialHeight * 1.5 : scrubberInitialHeight
            scrubberOuterCircleWidthConstraint?.constant = isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth
            scrubberOuterCircle?.layer.cornerRadius = (isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth) / 2
            scrubberOuterCircle?.layer.borderWidth = isSeeking ? 1.0 : 0
        }
    }
    
    public var fullscreen = false {
        didSet {
            fullscreenButton?.selected = fullscreen
        }
    }

    public var fullscreenDisabled: Bool {
        return container.options[kFullscreenDisabled] as? Bool ?? false
    }

    private var duration: CGFloat {
        return CGFloat(container.playback?.duration ?? 0.0)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }

    public init() {
        super.init(frame: CGRectZero)
    }
    
    public class func loadNib() -> UINib? {
        return UINib(nibName: "MediaControlView", bundle: NSBundle(forClass: MediaControl.self))
    }

    public class func initCustom() -> MediaControl {
        return MediaControl()
    }
    
    public class func create() -> MediaControl {
        var mediaControl: MediaControl!
        if let nib = loadNib() {
            mediaControl = nib.instantiateWithOwner(self, options: nil).last as! MediaControl
        } else {
            mediaControl = initCustom()
        }
        mediaControl.setupAspectFitButtonResize(mediaControl.playbackControlButton)
        mediaControl.scrubberInitialPosition = mediaControl.progressBarWidthConstraint?.constant ?? 0
        mediaControl.scrubberInitialHeight = mediaControl.scrubberOuterCircleHeightConstraint?.constant ?? 0
        mediaControl.scrubberInitialWidth = mediaControl.scrubberOuterCircleWidthConstraint?.constant ?? 0
        mediaControl.airPlayVolumeView?.showsVolumeSlider = false
        mediaControl.airPlayVolumeView?.showsRouteButton = true
        mediaControl.airPlayVolumeView?.backgroundColor = UIColor.clearColor()
        mediaControl.hide()
        mediaControl.bindOrientationChangedListener()
        if let seekBarView = mediaControl.seekBarView as? DragDetectorView {
            seekBarView.target = mediaControl
            seekBarView.selector = #selector(handleSeekbarViewTouch(_:))
        }
        return mediaControl
    }

    public func setupAspectFitButtonResize(button: UIButton?) {
        button?.contentHorizontalAlignment = .Fill
        button?.contentVerticalAlignment = .Fill
        button?.imageView?.contentMode = .ScaleAspectFit
    }

    public func imageFromName(name: String) -> UIImage? {
        return UIImage(named: name, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
    }
    
    public func updatePlaybackControlButtonIcon() {
        var image: UIImage?
        
        if playbackControlState == .Playing {
            image = livePlayback ? stopButtonImage : pauseButtonImage
        } else {
            image = playButtonImage
        }
        
        playbackControlButton?.setImage(image, forState: .Normal)
    }
    
    public func bindOrientationChangedListener() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MediaControl.didRotate),
            name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    public func didRotate() {
        updateBars()
        updateScrubberPosition()
    }
    
    public func setup(container: Container) {
        stopListening()
        self.container = container
        bindEventListeners()
        container.mediaControlEnabled ? enable() : disable()
        playbackControlState = container.isPlaying ? .Playing : .Stopped
        backgroundOverlayView?.backgroundColor = backgroundOverlayColor
        fullscreenButton?.hidden = fullscreenDisabled
    }
    
    public func bindEventListeners() {
        for (event, callback) in eventBindings() {
            listenTo(container, eventName: event.rawValue, callback: callback)
        }
    }
    
    public func eventBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play       : { [weak self] (info: EventUserInfo) in self?.triggerPlay() },
            .Pause      : { [weak self] (info: EventUserInfo) in self?.triggerPause() },
            .Ready      : { [weak self] (info: EventUserInfo) in self?.containerReady() },
            .TimeUpdated: { [weak self] (info: EventUserInfo) in self?.timeUpdated(info) },
            .Progress   : { [weak self] (info: EventUserInfo) in self?.progressUpdated(info) },
            .Buffering  : { [weak self] _ in self?.playbackBuffering() },
            .BufferFull : { [weak self] _ in self?.playbackBufferFull() },
            .Ended      : { [weak self] (info: EventUserInfo) in self?.playbackControlState = .Stopped },
            .MediaControlDisabled : { [weak self] (info: EventUserInfo) in self?.disable() },
            .MediaControlEnabled  : { [weak self] (info: EventUserInfo) in self?.enable() },
        ]
    }

    public func playbackBuffering() {
        playbackControlButton?.hidden = true
    }

    public func playbackBufferFull() {
        playbackControlButton?.hidden = false
    }
    
    public func triggerPlay() {
        playbackControlState = .Playing
        trigger(.Playing)
    }
    
    public func triggerPause() {
        playbackControlState = .Paused
        trigger(.NotPlaying)
    }
    
    public func disable() {
        enabled = false
        hide()
    }
    
    public func enable() {
        enabled = true
        show()
        scheduleTimerToHideControls()
    }
    
    public func timeUpdated(info: EventUserInfo) {
        guard let position = info!["position"] as? NSTimeInterval where !livePlayback else {
            return
        }
        
        currentTimeLabel?.text = DateFormatter.formatSeconds(position)
        seekPercentage = duration == 0 ? 0 : CGFloat(position) / duration
        updateScrubberPosition()
    }
    
    public func progressUpdated(info: EventUserInfo) {
        guard let end = info!["end_position"] as? CGFloat where !livePlayback else {
            return
        }
        
        bufferPercentage = duration == 0 ? 0 : end / duration
        updateBars()
    }
    
    public func updateScrubberPosition() {
        if let scrubberView = self.scrubberView,
            let seekBarView = self.seekBarView where !isSeeking {
            let delta = CGRectGetWidth(seekBarView.frame) * seekPercentage
            progressBarWidthConstraint?.constant = delta + scrubberInitialPosition
            scrubberView.setNeedsLayout()
            progressBarView?.setNeedsLayout()
        }
    }
    
    public func updateBars() {
        if let seekBarView = self.seekBarView,
            let bufferBarWidthConstraint = self.bufferBarWidthConstraint {
            bufferBarWidthConstraint.constant = seekBarView.frame.size.width * bufferPercentage
            bufferBarView?.layoutIfNeeded()
        }
    }
    
    public func containerReady() {
        livePlayback = container.playback?.playbackType == .Live
        livePlayback ? setupForLive() : setupForVOD()
        updateBars()
        updateScrubberPosition()
        updatePlaybackControlButtonIcon()
    }
    
    public func setupForLive() {
        seekPercentage = 1
        progressBarView?.backgroundColor = liveProgressBarColor
    }
    
    public func setupForVOD() {
        progressBarView?.backgroundColor = vodProgressBarColor
        durationLabel?.text = DateFormatter.formatSeconds(container.playback?.duration ?? 0.0)
    }
    
    public func hide() {
        hideControlsTimer?.invalidate()
        trigger(PlayerEvent.MediaControlHide.rawValue)
        setSubviewsVisibility(hidden: true)
    }
    
    public func show() {
        trigger(PlayerEvent.MediaControlShow.rawValue)
        setSubviewsVisibility(hidden: false)
        scheduleTimerToHideControls()
    }

    public func showAnimated() {
        trigger(PlayerEvent.MediaControlShow.rawValue)
        setSubviewsVisibility(hidden: false, animated: true)
        scheduleTimerToHideControls()
    }
    
    public func hideAnimated() {
        hideControlsTimer?.invalidate()
        trigger(PlayerEvent.MediaControlHide.rawValue)
        setSubviewsVisibility(hidden: true, animated: true)
    }
    
    private func setSubviewsVisibility(hidden hidden: Bool, animated: Bool = false) {
        if (!hidden && !enabled) {
            return
        }
        
        let duration = animated ? animationDuration : 0
        
        UIView.animateWithDuration(duration, animations: {
            for subview in self.subviews {
                subview.alpha = hidden ? 0 : 1
            }
        })
        
        userInteractionEnabled = !hidden
        controlsHidden = hidden
    }
    
    public func toggleVisibility() {
        controlsHidden ? showAnimated() : hideAnimated()
    }

    @IBAction public func togglePlay(sender: UIButton) {
        if playbackControlState == .Playing {
            livePlayback ? stop() : pause()
        } else {
            play()
        }
        scheduleTimerToHideControls()
    }
    
    @IBAction public func toggleFullscreen(sender: UIButton) {
        fullscreen = !fullscreen
        let event = fullscreen ? MediaControlEvent.FullscreenEnter : MediaControlEvent.FullscreenExit
        trigger(event.rawValue)
        scheduleTimerToHideControls()
        updateScrubberPosition()
    }
    
    private func pause() {
        playbackControlState = .Paused
        container.pause()
        trigger(MediaControlEvent.NotPlaying.rawValue)
    }
    
    private func play() {
        playbackControlState = .Playing
        container.play()
        trigger(MediaControlEvent.Playing.rawValue)
    }
    
    private func stop() {
        playbackControlState = .Stopped
        container.stop()
        trigger(MediaControlEvent.NotPlaying.rawValue)
    }
    
    public func scheduleTimerToHideControls() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(3.0,
            target: self, selector: #selector(MediaControl.hideAfterPlay), userInfo: nil, repeats: false)
    }
    
    func hideAfterPlay() {
        hideControlsTimer?.invalidate()
        if container.isPlaying {
            hideAnimated()
        } else {
            listenToOnce(container, eventName: ContainerEvent.Play.rawValue, callback: { [weak self] _ in self?.hideAnimated() })
        }
    }

    public func handleSeekbarViewTouch(view: DragDetectorView) {
        if let touch = view.currentTouch where !livePlayback {
            let touchPoint = touch.locationInView(seekBarView)
            progressBarWidthConstraint?.constant = touchPoint.x + scrubberInitialPosition
            scrubberLabel?.text = DateFormatter.formatSeconds(secondsRelativeToPoint(touchPoint))
            scrubberView?.setNeedsLayout()
            switch view.touchState {
            case .Began:
                isSeeking = true
                hideControlsTimer?.invalidate()
            case .Ended:
                container.seek(secondsRelativeToPoint(touchPoint))
                isSeeking = false
                scheduleTimerToHideControls()
            default: break
            }
        }
    }
    
    public func secondsRelativeToPoint(touchPoint: CGPoint) -> Double {
        if let seekBarView = self.seekBarView,
            let scrubberView = self.scrubberView {
            let width = seekBarView.frame.width - scrubberView.frame.width
            let positionPercentage = max(0, min(touchPoint.x / width, 100))
            return Double(duration * positionPercentage)
        }
        return 0
    }

    private func trigger(event: MediaControlEvent) {
        trigger(event.rawValue)
    }
    
    deinit {
        stopListening()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
