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

    @IBOutlet open weak var airPlayVolumeView: MPVolumeView?

    internal(set) open weak var container: Container?
    internal(set) open var controlsHidden = false

    open var bufferPercentage: CGFloat = 0.0
    open var seekPercentage: CGFloat = 0.0
    open var scrubberInitialPosition: CGFloat = 0.0
    open var scrubberInitialWidth: CGFloat = 0.0
    open var scrubberInitialHeight: CGFloat = 0.0
    open var hideControlsTimer: Timer?
    open var enabled = false
    open var livePlayback = false

    open lazy var liveProgressBarColor = UIColor.red
    open lazy var vodProgressBarColor = UIColor.blue
    open lazy var backgroundOverlayColor = UIColor.black.withAlphaComponent(0.2)
    open lazy var playButtonImage: UIImage? = self.imageFromName("play")
    open lazy var pauseButtonImage: UIImage? = self.imageFromName("pause")
    open lazy var stopButtonImage: UIImage? = self.imageFromName("stop")

    open var playbackControlState: PlaybackControlState = .stopped {
        didSet {
            updatePlaybackControlButtonIcon()
        }
    }

    open var isSeeking = false {
        didSet {
            scrubberTimeView?.isHidden = !isSeeking
            scrubberOuterCircleHeightConstraint?.constant = isSeeking ? scrubberInitialHeight * 1.5 : scrubberInitialHeight
            scrubberOuterCircleWidthConstraint?.constant = isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth
            scrubberOuterCircle?.layer.cornerRadius = (isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth) / 2
            scrubberOuterCircle?.layer.borderWidth = isSeeking ? 1.0 : 0
        }
    }

    open var fullscreen = false {
        didSet {
            fullscreenButton?.isSelected = fullscreen
        }
    }

    open var fullscreenDisabled: Bool {
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

    open class func loadNib() -> UINib? {
        return UINib(nibName: "MediaControlView", bundle: Bundle(for: MediaControl.self))
    }

    open class func initCustom() -> MediaControl {
        return MediaControl()
    }

    open class func create() -> MediaControl {
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
        mediaControl.airPlayVolumeView?.showsVolumeSlider = false
        mediaControl.airPlayVolumeView?.showsRouteButton = true
        mediaControl.airPlayVolumeView?.backgroundColor = UIColor.clear
        mediaControl.hide()
        mediaControl.bindOrientationChangedListener()
        if let seekBarView = mediaControl.seekBarView as? DragDetectorView {
            seekBarView.target = mediaControl
            seekBarView.selector = #selector(handleSeekbarViewTouch(_:))
        }
        return mediaControl
    }

    open func setupAspectFitButtonResize(_ button: UIButton?) {
        button?.contentHorizontalAlignment = .fill
        button?.contentVerticalAlignment = .fill
        button?.imageView?.contentMode = .scaleAspectFit
    }

    open func imageFromName(_ name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: type(of: self)), compatibleWith: nil)
    }

    open func updatePlaybackControlButtonIcon() {
        var image: UIImage?

        if playbackControlState == .playing {
            image = livePlayback ? stopButtonImage : pauseButtonImage
        } else {
            image = playButtonImage
        }

        playbackControlButton?.setImage(image, for: UIControlState())
    }

    open func bindOrientationChangedListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(MediaControl.didRotate),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    open func didRotate() {
        updateBars()
        updateScrubberPosition()
    }

    open func setup(_ container: Container) {
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

    open func bindEventListeners() {
        if let container = self.container {
            listenTo(container, eventName: Event.disableMediaControl.rawValue) { [weak self] _ in self?.disable() }
            listenTo(container, eventName: Event.enableMediaControl.rawValue) { [weak self] _ in self?.enable() }
        }

        if let playback = container?.playback {
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.triggerPlay() }
            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in self?.triggerPause() }
            listenTo(playback, eventName: Event.stalled.rawValue) { [weak self] _ in self?.playbackStalled() }
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in self?.playbackReady() }
            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in self?.playbackControlState = .stopped }
            listenTo(playback, eventName: Event.positionUpdate.rawValue) { [weak self] (info: EventUserInfo) in self?.timeUpdated(info) }
            listenTo(playback, eventName: Event.bufferUpdate.rawValue) { [weak self] (info: EventUserInfo) in self?.progressUpdated(info) }
        }
    }

    func playbackStalled() {
        playbackControlButton?.isHidden = true
    }

    open func triggerPlay() {
        playbackControlState = .playing
        playbackControlButton?.isHidden = false
        trigger(Event.playing)
    }

    open func triggerPause() {
        playbackControlState = .paused
        trigger(Event.didPause)
    }

    open func disable() {
        enabled = false
        hide()
    }

    open func enable() {
        enabled = true
        show()
        scheduleTimerToHideControls()
    }

    open func timeUpdated(_ info: EventUserInfo) {
        guard let position = info!["position"] as? TimeInterval, !livePlayback else {
            return
        }

        currentTimeLabel?.text = DateFormatter.formatSeconds(position)
        seekPercentage = duration == 0 ? 0 : CGFloat(position) / duration
        updateScrubberPosition()
    }

    open func progressUpdated(_ info: EventUserInfo) {
        guard let end = info!["end_position"] as? CGFloat, !livePlayback else {
            return
        }

        bufferPercentage = duration == 0 ? 0 : end / duration
        updateBars()
    }

    open func updateScrubberPosition() {
        if let scrubberView = self.scrubberView,
            let seekBarView = self.seekBarView, !isSeeking {
            let delta = seekBarView.frame.width * seekPercentage
            progressBarWidthConstraint?.constant = delta + scrubberInitialPosition
            scrubberView.setNeedsLayout()
            progressBarView?.setNeedsLayout()
        }
    }

    open func updateBars() {
        if let seekBarView = self.seekBarView,
            let bufferBarWidthConstraint = self.bufferBarWidthConstraint {
            bufferBarWidthConstraint.constant = seekBarView.frame.size.width * bufferPercentage
            bufferBarView?.layoutIfNeeded()
        }
    }

    open func playbackReady() {
        livePlayback = container?.playback?.playbackType == .live
        livePlayback ? setupForLive() : setupForVOD()
        updateBars()
        updateScrubberPosition()
        updatePlaybackControlButtonIcon()
    }

    open func setupForLive() {
        seekPercentage = 1
        progressBarView?.backgroundColor = liveProgressBarColor
    }

    open func setupForVOD() {
        progressBarView?.backgroundColor = vodProgressBarColor
        durationLabel?.text = DateFormatter.formatSeconds(container?.playback?.duration ?? 0.0)
    }

    open func hide() {
        hideControlsTimer?.invalidate()
        trigger(Event.disableMediaControl.rawValue)
        setSubviewsVisibility(hidden: true)
    }

    open func show() {
        trigger(Event.enableMediaControl.rawValue)
        setSubviewsVisibility(hidden: false)
        scheduleTimerToHideControls()
    }

    open func showAnimated() {
        trigger(Event.enableMediaControl.rawValue)
        setSubviewsVisibility(hidden: false, animated: true)
        scheduleTimerToHideControls()
    }

    open func hideAnimated() {
        hideControlsTimer?.invalidate()
        trigger(Event.disableMediaControl.rawValue)
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

    open func toggleVisibility() {
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
        fullscreen = !fullscreen
        let event = fullscreen ? Event.requestFullscreen : Event.exitFullscreen
        trigger(event.rawValue)
        scheduleTimerToHideControls()
        updateScrubberPosition()
    }

    fileprivate func pause() {
        playbackControlState = .paused
        container?.playback?.pause()
        trigger(Event.didPause.rawValue)
    }

    fileprivate func play() {
        playbackControlState = .playing
        container?.playback?.play()
        trigger(Event.playing.rawValue)
    }

    fileprivate func stop() {
        playbackControlState = .stopped
        container?.playback?.stop()
        trigger(Event.didStop.rawValue)
    }

    open func scheduleTimerToHideControls() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                                 target: self, selector: #selector(MediaControl.hideAfterPlay), userInfo: nil, repeats: false)
    }

    func hideAfterPlay() {
        hideControlsTimer?.invalidate()
        if isPlaybackPlaying() {
            hideAnimated()
        } else if let playback = container?.playback {
            listenToOnce(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.hideAnimated() }
        }
    }

    open func handleSeekbarViewTouch(_ view: DragDetectorView) {
        if let touch = view.currentTouch, !livePlayback {
            let touchPoint = touch.location(in: seekBarView)
            progressBarWidthConstraint?.constant = touchPoint.x + scrubberInitialPosition
            scrubberLabel?.text = DateFormatter.formatSeconds(secondsRelativeToPoint(touchPoint))
            scrubberView?.setNeedsLayout()
            switch view.touchState {
            case .began:
                isSeeking = true
                hideControlsTimer?.invalidate()
            case .ended:
                container?.playback?.seek(secondsRelativeToPoint(touchPoint))
                isSeeking = false
                scheduleTimerToHideControls()
            default: break
            }
        }
    }

    open func secondsRelativeToPoint(_ touchPoint: CGPoint) -> Double {
        if let seekBarView = self.seekBarView,
            let scrubberView = self.scrubberView {
            let width = seekBarView.frame.width - scrubberView.frame.width
            let positionPercentage = max(0, min(touchPoint.x / width, 100))
            return Double(duration * positionPercentage)
        }
        return 0
    }

    open func destroy() {
        Logger.logDebug("destroying", scope: "MediaCotrol")
        Logger.logDebug("destroying listeners", scope: "MediaCotrol")
        stopListening()
        NotificationCenter.default.removeObserver(self)
        Logger.logDebug("destroyed", scope: "MediaCotrol")
    }
}
