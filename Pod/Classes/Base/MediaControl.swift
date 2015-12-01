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
    @IBOutlet weak public var playPauseButton: UIButton!
    
    public internal(set) var container: Container!
    public internal(set) var controlsHidden = false
    
    private var bufferPercentage:CGFloat = 0.0
    private var seekPercentage:CGFloat = 0.0
    private var scrubberInitialPosition: CGFloat!
    private var hideControlsTimer: NSTimer!
    
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
    }
    
    public class func initWithContainer(container: Container) -> MediaControl {
        let nib = UINib(nibName: "MediaControlView", bundle: NSBundle(forClass: MediaControl.self))
        let mediaControl = nib.instantiateWithOwner(self, options: nil).last as! MediaControl
        mediaControl.container = container
        mediaControl.setup()
        return mediaControl
    }
    
    private func setup() {
        bindEventListeners()
        backgroundColor = UIColor.clearColor()
        scrubberInitialPosition = scrubberLeftConstraint.constant
    }
    
    private func bindEventListeners() {
        for (event, callback) in eventBindings() {
            listenTo(container, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func eventBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play       : { [weak self] _ in self?.trigger(.Playing) },
            .Pause      : { [weak self] _ in self?.trigger(.NotPlaying) },
            .Ready      : { [weak self] _ in self?.containerReady() },
            .TimeUpdated: { [weak self] info in self?.timeUpdated(info) },
            .Progress   : { [weak self] info in self?.progressUpdated(info) },
            .Ended      : { [weak self] _ in self?.playPauseButton.selected = false }
        ]
    }
    
    private func timeUpdated(info: EventUserInfo) {
        guard let position = info!["position"] as? NSTimeInterval else {
            return
        }
        
        currentTimeLabel.text = DateFormatter.formatSeconds(position)
        seekPercentage = duration == 0 ? 0 : CGFloat(position) / duration
        updateScrubberPosition()
    }
    
    private func progressUpdated(info: EventUserInfo) {
        guard let end = info!["end_position"] as? CGFloat else {
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
        let duration = animated ? animationDuration : 0
        
        UIView.animateWithDuration(duration, animations: {
            for subview in self.subviews {
                subview.alpha = hidden ? 0 : 1
            }
        })
        
        self.controlsHidden = hidden
    }
    
    @IBAction func toggleVisibility(sender: AnyObject) {
        controlsHidden ? showAnimated() : hideAnimated()
    }

    @IBAction func togglePlay(sender: UIButton) {
        if container.isPlaying {
            pause()
        } else {
            play()
            scheduleTimerToHideControls()
        }
    }
    
    private func pause() {
        playPauseButton.selected = false
        container.pause()
        trigger(MediaControlEvent.NotPlaying.rawValue)
    }
    
    private func play() {
        playPauseButton.selected = true
        container.play()
        trigger(MediaControlEvent.Playing.rawValue)
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
}