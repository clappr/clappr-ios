import Foundation

public class MediaControl: UIBaseObject {
    private let animationDuration = 0.3
    
    @IBOutlet weak var seekBarView: UIView!
    @IBOutlet weak var bufferBarView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var scrubberView: ScrubberView!
    @IBOutlet weak var scrubberLabel: UILabel!
    @IBOutlet weak var bufferBarWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var scrubberLeftConstraint: NSLayoutConstraint!

    @IBOutlet weak public var durationLabel: UILabel!
    @IBOutlet weak public var currentTimeLabel: UILabel!
    @IBOutlet weak public var controlsOverlayView: GradientView!
    @IBOutlet weak public var controlsWrapperView: UIView!
    @IBOutlet weak public var playbackControlButton: UIButton!
    
    public internal(set) var container: Container!
    public internal(set) var controlsHidden = false
    
    private var bufferPercentage: CGFloat = 0.0
    private var seekPercentage: CGFloat = 0.0
    private var scrubberInitialPosition: CGFloat!
    private var hideControlsTimer: NSTimer!
    private var enabled = false
    private var livePlayback = false
    
    public var playbackControlState: PlaybackControlState = .Stopped {
        didSet {
            updatePlaybackControlButtonIcon()
        }
    }
    
    private var isSeeking = false {
        didSet {
            scrubberLabel.hidden = !isSeeking
        }
    }
    
    private var duration: CGFloat {
        get {
            return CGFloat(container.playback.duration())
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    public class func initFromNib() -> MediaControl {
        let nib = UINib(nibName: "MediaControlView", bundle: NSBundle(forClass: MediaControl.self))
        let mediaControl = nib.instantiateWithOwner(self, options: nil).last as! MediaControl
        mediaControl.scrubberInitialPosition = mediaControl.scrubberLeftConstraint.constant
        mediaControl.hide()
        mediaControl.bindOrientationChangedListener()
        return mediaControl
    }
    
    private func updatePlaybackControlButtonIcon() {
        var imageName: String
        
        if playbackControlState == .Playing {
            imageName = livePlayback ? "stop" : "pause"
        } else {
            imageName = "play"
        }
        
        let image = UIImage(named: imageName, inBundle: NSBundle(forClass: MediaControl.self),
            compatibleWithTraitCollection: nil)
        playbackControlButton.setImage(image, forState: .Normal)
    }
    
    private func bindOrientationChangedListener() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate",
            name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func didRotate() {
        updateBars()
        updateScrubberPosition()
    }
    
    public func setup(container: Container) {
        stopListening()
        self.container = container
        bindEventListeners()
        container.mediaControlEnabled ? enable() : disable()
        playbackControlState = container.isPlaying ? .Playing : .Stopped
    }
    
    private func bindEventListeners() {
        for (event, callback) in eventBindings() {
            listenTo(container, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func eventBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play       : { [weak self] _ in self?.triggerPlay() },
            .Pause      : { [weak self] _ in self?.triggerPause() },
            .Ready      : { [weak self] _ in self?.containerReady() },
            .TimeUpdated: { [weak self] info in self?.timeUpdated(info) },
            .Progress   : { [weak self] info in self?.progressUpdated(info) },
            .Ended      : { [weak self] _ in self?.playbackControlState = .Stopped },
            .MediaControlDisabled : { [weak self] _ in self?.disable() },
            .MediaControlEnabled  : { [weak self] _ in self?.enable() },
        ]
    }
    
    private func triggerPlay() {
        playbackControlState = .Playing
        trigger(.Playing)
    }
    
    private func triggerPause() {
        playbackControlState = .Paused
        trigger(.NotPlaying)
    }
    
    private func disable() {
        enabled = false
        hide()
    }
    
    private func enable() {
        enabled = true
        show()
    }
    
    private func timeUpdated(info: EventUserInfo) {
        guard let position = info!["position"] as? NSTimeInterval where !livePlayback else {
            return
        }
        
        currentTimeLabel.text = DateFormatter.formatSeconds(position)
        seekPercentage = duration == 0 ? 0 : CGFloat(position) / duration
        updateScrubberPosition()
    }
    
    private func progressUpdated(info: EventUserInfo) {
        guard let end = info!["end_position"] as? CGFloat where !livePlayback else {
            return
        }
        
        bufferPercentage = duration == 0 ? 0 : end / duration
        updateBars()
    }
    
    private func updateScrubberPosition() {
        if !isSeeking {
            let delta = CGRectGetWidth(seekBarView.frame) * seekPercentage
            scrubberLeftConstraint.constant = delta + scrubberInitialPosition
            scrubberView.setNeedsLayout()
            progressBarView.setNeedsLayout()
        }
    }
    
    private func updateBars() {
        bufferBarWidthContraint.constant = seekBarView.frame.size.width * bufferPercentage
        bufferBarView.layoutIfNeeded()
    }
    
    private func containerReady() {
        livePlayback = container.playback.type() == .Live
        livePlayback ? setupForLive() : setupForVOD()
        updateBars()
        updatePlaybackControlButtonIcon()
    }
    
    private func setupForLive() {
        bufferPercentage = 1
        bufferBarView.backgroundColor = UIColor.redColor()
        durationLabel.text = ""
        currentTimeLabel.text = ""
    }
    
    private func setupForVOD() {
        bufferBarView.backgroundColor = UIColor.whiteColor()
        durationLabel.text = DateFormatter.formatSeconds(container.playback.duration())
    }
    
    public func hide() {
        setSubviewsVisibility(hidden: true)
    }
    
    public func show() {
        setSubviewsVisibility(hidden: false)
    }

    public func showAnimated() {
        setSubviewsVisibility(hidden: false, animated: true)
    }
    
    public func hideAnimated() {
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

    @IBAction func togglePlay(sender: UIButton) {
        if playbackControlState == .Playing {
            livePlayback ? stop() : pause()
        } else {
            play()
            scheduleTimerToHideControls()
        }
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
    
    private func scheduleTimerToHideControls() {
        hideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(3.0,
            target: self, selector: "hideAfterPlay", userInfo: nil, repeats: false)
    }
    
    func hideAfterPlay() {
        if container.isPlaying {
            hideAnimated()
        }
        
        hideControlsTimer.invalidate()
    }
    
    @IBAction func handleScrubberPan(panGesture: UIPanGestureRecognizer) {
        let touchPoint = panGesture.locationInView(seekBarView)
        
        switch panGesture.state {
        case .Began:
            isSeeking = true
        case .Changed:
            scrubberLeftConstraint.constant = touchPoint.x + scrubberInitialPosition
            scrubberLabel.text = DateFormatter.formatSeconds(secondsRelativeToPoint(touchPoint))
            scrubberView.setNeedsLayout()
        case .Ended:
            container.seekTo(secondsRelativeToPoint(touchPoint))
            isSeeking = false
        default: break
        }
    }
    
    private func secondsRelativeToPoint(touchPoint: CGPoint) -> Double {
        let positionPercentage = touchPoint.x / seekBarView.frame.size.width
        return Double(duration * positionPercentage)
    }

    private func trigger(event: MediaControlEvent) {
        trigger(event.rawValue)
    }
    
    deinit {
        stopListening()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}