import Foundation

import MediaPlayer

open class MediaControl: UIBaseObject {
    fileprivate let animationDuration = 0.3

    @IBOutlet open var seekBarView: UIView?
    @IBOutlet open var bufferBarView: UIView?
    @IBOutlet open var progressBarView: UIView?
    @IBOutlet open var scrubberTimeView: UIView?
    @IBOutlet open var scrubberLabel: UILabel?
    @IBOutlet open var scrubberView: UIView?
    @IBOutlet open var scrubberOuterCircle: UIView?

    @IBOutlet open var scrubberOuterCircleWidthConstraint: NSLayoutConstraint?
    @IBOutlet open var scrubberOuterCircleHeightConstraint: NSLayoutConstraint?
    @IBOutlet open var bufferBarWidthConstraint: NSLayoutConstraint?
    @IBOutlet open var progressBarWidthConstraint: NSLayoutConstraint?

    @IBOutlet open var durationLabel: UILabel?
    @IBOutlet open var currentTimeLabel: UILabel?

    @IBOutlet open var backgroundOverlayView: UIView?

    @IBOutlet open var controlsOverlayView: UIView?
    @IBOutlet open var controlsWrapperView: UIView?
    @IBOutlet open var playbackControlButton: UIButton?
    @IBOutlet open var fullscreenButton: UIButton?

    #if os(iOS)
    @IBOutlet open var airPlayVolumeView: MPVolumeView?
    #endif

    @objc internal(set) open weak var container: Container?
    @objc internal(set) open var controlsHidden = false
    @objc open weak var core: Core?

    @objc open var bufferPercentage: CGFloat = 0.0
    @objc open var seekPercentage: CGFloat = 0.0
    @objc open var scrubberInitialPosition: CGFloat = 0.0
    @objc open var scrubberInitialWidth: CGFloat = 0.0
    @objc open var scrubberInitialHeight: CGFloat = 0.0
    @objc open var hideControlsTimer: Timer?
    @objc open var enabled = false
    @objc open var livePlayback = false

    @objc open lazy var liveProgressBarColor = UIColor.red
    @objc open lazy var vodProgressBarColor = UIColor.blue
    @objc open lazy var backgroundOverlayColor = UIColor.black.withAlphaComponent(0.2)
    @objc open lazy var playButtonImage: UIImage? = self.imageFromName("play")
    @objc open lazy var pauseButtonImage: UIImage? = self.imageFromName("pause")
    @objc open lazy var stopButtonImage: UIImage? = self.imageFromName("stop")

    open var playbackControlState: PlaybackControlState = .stopped {
        didSet {
            updatePlaybackControlButtonIcon()
        }
    }

    @objc open var isSeeking = false {
        didSet {
            scrubberTimeView?.isHidden = !isSeeking
            scrubberOuterCircleHeightConstraint?.constant = isSeeking ? scrubberInitialHeight * 1.5 : scrubberInitialHeight
            scrubberOuterCircleWidthConstraint?.constant = isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth
            scrubberOuterCircle?.layer.cornerRadius = (isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth) / 2
            scrubberOuterCircle?.layer.borderWidth = isSeeking ? 1.0 : 0
        }
    }

    @objc var fullscreen = false {
        didSet {
            fullscreenButton?.isSelected = fullscreen
        }
    }

    @objc open var fullscreenDisabled: Bool {
        return container?.options[kFullscreenDisabled] as? Bool ?? false
    }

    fileprivate var duration: CGFloat {
        return CGFloat(container?.playback?.duration ?? 0.0)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }

    public init() {
        super.init(frame: CGRect.zero)
    }

    @objc open class func loadNib() -> UINib? {
        return UINib(nibName: "MediaControlView", bundle: Bundle(for: MediaControl.self))
    }

    @objc open class func initCustom() -> MediaControl {
        return MediaControl()
    }

    @objc open class func create() -> MediaControl {
        var mediaControl: MediaControl!
        if let nib = loadNib(),
            let control = nib.instantiate(withOwner: self, options: nil).last as? MediaControl {
            mediaControl = control
        } else {
            mediaControl = initCustom()
        }
        mediaControl.setupAspectFitButtonResize(mediaControl.playbackControlButton)
        mediaControl.scrubberInitialPosition = mediaControl.progressBarWidthConstraint?.constant ?? 0
        mediaControl.scrubberInitialHeight = mediaControl.scrubberOuterCircleHeightConstraint?.constant ?? 0
        mediaControl.scrubberInitialWidth = mediaControl.scrubberOuterCircleWidthConstraint?.constant ?? 0
        #if os(iOS)
        mediaControl.airPlayVolumeView?.showsVolumeSlider = false
        mediaControl.airPlayVolumeView?.showsRouteButton = true
        mediaControl.airPlayVolumeView?.backgroundColor = UIColor.clear
        #endif
        mediaControl.hide()
        mediaControl.bindOrientationChangedListener()
        if let seekBarView = mediaControl.seekBarView as? DragDetectorView {
            seekBarView.target = mediaControl
            seekBarView.selector = #selector(handleSeekbarViewTouch(_:))
        }
        return mediaControl
    }

    @objc open func setupAspectFitButtonResize(_ button: UIButton?) {
        button?.contentHorizontalAlignment = .fill
        button?.contentVerticalAlignment = .fill
        button?.imageView?.contentMode = .scaleAspectFit
    }

    @objc open func imageFromName(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: type(of: self)), compatibleWith: nil)
    }

    @objc open func updatePlaybackControlButtonIcon() {
        var image: UIImage?

        if playbackControlState == .playing {
            image = livePlayback ? stopButtonImage : pauseButtonImage
        } else {
            image = playButtonImage
        }

        playbackControlButton?.setImage(image, for: UIControlState())
    }

    @objc open func bindOrientationChangedListener() {
        #if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(MediaControl.didRotate),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        #endif
    }

    @objc open func didRotate() {
        updateBars()
        updateScrubberPosition()
    }

    @objc open func setup(_ container: Container) {
        self.container = container
        setupBindings()
        container.mediaControlEnabled ? enable() : disable()
        playbackControlState = isPlaybackPlaying() ? .playing : .stopped
        backgroundOverlayView?.backgroundColor = backgroundOverlayColor
        fullscreenButton?.isHidden = fullscreenDisabled
    }

    private func isPlaybackPlaying() -> Bool {
        return container?.playback?.isPlaying ?? false
    }

    private func setupBindings() {
        bindEventListeners()

        container?.on(InternalEvent.didChangePlayback.rawValue) { [weak self] _ in
            self?.stopListening()
            self?.bindEventListeners()
        }
    }

    @objc open func bindEventListeners() {

        if let core = self.core {
            listenTo(core, eventName: InternalEvent.didExitFullscreen.rawValue) { [weak self] _ in self?.fullscreen = false }
            listenTo(core, eventName: InternalEvent.didEnterFullscreen.rawValue) { [weak self] _ in self?.fullscreen = true }
        }

        if let container = self.container {
            listenTo(container, eventName: Event.disableMediaControl.rawValue) { [weak self] _ in self?.disable() }
            listenTo(container, eventName: Event.enableMediaControl.rawValue) { [weak self] _ in self?.enable() }
        }

        if let playback = container?.playback {
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.triggerPlay() }
            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in self?.triggerPause() }
            listenTo(playback, eventName: Event.stalling.rawValue) { [weak self] _ in self?.playbackStalled() }
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in self?.playbackReady() }
            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in self?.playbackControlState = .stopped }
            listenTo(playback, eventName: Event.didUpdatePosition.rawValue) { [weak self] (info: EventUserInfo) in self?.timeUpdated(info) }
            listenTo(playback, eventName: Event.didUpdateBuffer.rawValue) { [weak self] (info: EventUserInfo) in self?.progressUpdated(info) }
        }
    }

    @objc func playbackStalled() {
        playbackControlButton?.isHidden = true
    }

    @objc open func triggerPlay() {
        playbackControlState = .playing
        playbackControlButton?.isHidden = false
    }

    @objc open func triggerPause() {
        playbackControlState = .paused
    }

    @objc open func disable() {
        enabled = false
        hide()
    }

    @objc open func enable() {
        enabled = true
        show()
        scheduleTimerToHideControls()
    }

    @objc open func timeUpdated(_ info: EventUserInfo) {
        guard let position = info!["position"] as? TimeInterval, !livePlayback else {
            return
        }

        currentTimeLabel?.text = ClapprDateFormatter.formatSeconds(position)
        seekPercentage = duration == 0 ? 0 : CGFloat(position) / duration
        updateScrubberPosition()
    }

    @objc open func progressUpdated(_ info: EventUserInfo) {
        guard let end = info!["end_position"] as? CGFloat, !livePlayback else {
            return
        }

        bufferPercentage = duration == 0 ? 0 : end / duration
        updateBars()
    }

    @objc open func updateScrubberPosition() {
        if let scrubberView = self.scrubberView,
            let seekBarView = self.seekBarView, !isSeeking {
            let delta = seekBarView.frame.width * seekPercentage
            progressBarWidthConstraint?.constant = delta + scrubberInitialPosition
            scrubberView.setNeedsLayout()
            progressBarView?.setNeedsLayout()
        }
    }

    @objc open func updateBars() {
        if let seekBarView = self.seekBarView,
            let bufferBarWidthConstraint = self.bufferBarWidthConstraint {
            bufferBarWidthConstraint.constant = seekBarView.frame.size.width * bufferPercentage
            bufferBarView?.layoutIfNeeded()
        }
    }

    @objc open func playbackReady() {
        livePlayback = container?.playback?.playbackType == .live
        livePlayback ? setupForLive() : setupForVOD()
        updateBars()
        updateScrubberPosition()
        updatePlaybackControlButtonIcon()
    }

    @objc open func setupForLive() {
        seekPercentage = 1
        progressBarView?.backgroundColor = liveProgressBarColor
    }

    @objc open func setupForVOD() {
        progressBarView?.backgroundColor = vodProgressBarColor
        durationLabel?.text = ClapprDateFormatter.formatSeconds(container?.playback?.duration ?? 0.0)
    }

    @objc open func hide() {
        hideControlsTimer?.invalidate()
        setSubviewsVisibility(hidden: true)
    }

    @objc open func show() {
        setSubviewsVisibility(hidden: false)
        scheduleTimerToHideControls()
    }

    @objc open func showAnimated() {
        setSubviewsVisibility(hidden: false, animated: true)
        scheduleTimerToHideControls()
    }

    @objc open func hideAnimated() {
        hideControlsTimer?.invalidate()
        setSubviewsVisibility(hidden: true, animated: true)
    }

    fileprivate func setSubviewsVisibility(hidden: Bool, animated: Bool = false) {
        if !hidden && !enabled {
            return
        }

        let duration = animated ? animationDuration : 0

        UIView.animate(withDuration: duration, animations: {
            for subview in self.subviews {
                subview.alpha = hidden ? 0 : 1
            }
        })

        isUserInteractionEnabled = !hidden
        controlsHidden = hidden
    }

    @objc open func toggleVisibility() {
        controlsHidden ? showAnimated() : hideAnimated()
    }

    @IBAction open func togglePlay(_: UIButton) {
        if playbackControlState == .playing {
            livePlayback ? stop() : pause()
        } else {
            play()
        }
        scheduleTimerToHideControls()
    }

    @IBAction open func toggleFullscreen(_: UIButton) {
        if fullscreen {
            trigger(InternalEvent.userRequestExitFullscreen.rawValue)
        } else {
            trigger(InternalEvent.userRequestEnterInFullscreen.rawValue)
        }
        scheduleTimerToHideControls()
        updateScrubberPosition()
    }

    fileprivate func pause() {
        playbackControlState = .paused
        container?.playback?.pause()
    }

    fileprivate func play() {
        playbackControlState = .playing
        container?.playback?.play()
    }

    fileprivate func stop() {
        playbackControlState = .stopped
        container?.playback?.stop()
    }

    @objc open func scheduleTimerToHideControls() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                                 target: self, selector: #selector(MediaControl.hideAfterPlay), userInfo: nil, repeats: false)
    }

    @objc func hideAfterPlay() {
        hideControlsTimer?.invalidate()
        if isPlaybackPlaying() {
            hideAnimated()
        } else if let playback = container?.playback {
            listenToOnce(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.hideAnimated() }
        }
    }

    @objc open func handleSeekbarViewTouch(_ view: DragDetectorView) {
        if let touch = view.currentTouch, !livePlayback {
            let touchPoint = touch.location(in: seekBarView)
            progressBarWidthConstraint?.constant = touchPoint.x + scrubberInitialPosition
            scrubberLabel?.text = ClapprDateFormatter.formatSeconds(secondsRelativeToPoint(touchPoint))
            scrubberView?.setNeedsLayout()
            switch view.touchState {
            case .began:
                isSeeking = true
                hideControlsTimer?.invalidate()
                toggleScrollEnable(in: view, to: false)
            case .ended:
                container?.playback?.seek(secondsRelativeToPoint(touchPoint))
                isSeeking = false
                scheduleTimerToHideControls()
                toggleScrollEnable(in: view, to: true)
            default: break
            }
        }
    }
    
    //This function was necessary because our apps were using the player inside
    //a scrollview, so a conflict was happening between the swipe event in the
    //slider and the scrollview.
    private func toggleScrollEnable(in view: UIView?,to isEnabled: Bool) {
        guard let view = view else {
            return
        }
        if let scrollView = view as? UIScrollView {
            scrollView.isScrollEnabled = isEnabled
        }
        toggleScrollEnable(in: view.superview, to: isEnabled)
    }

    @objc open func secondsRelativeToPoint(_ touchPoint: CGPoint) -> Double {
        if let seekBarView = self.seekBarView,
            let scrubberView = self.scrubberView {
            let width = seekBarView.frame.width - scrubberView.frame.width
            let positionPercentage = max(0, min(touchPoint.x / width, 100))
            return Double(duration * positionPercentage)
        }
        return 0
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "MediaCotrol")
        Logger.logDebug("destroying listeners", scope: "MediaCotrol")
        stopListening()
        NotificationCenter.default.removeObserver(self)
        Logger.logDebug("destroyed", scope: "MediaCotrol")
    }
}
