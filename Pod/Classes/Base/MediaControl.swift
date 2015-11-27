import Foundation

public class MediaControl: UIBaseObject {
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
    
    private var bufferPercentage:CGFloat = 0.0
    private var seekPercentage:CGFloat = 0.0
    private var isSeeking = false
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
        mediaControl.bindEventListeners()
        mediaControl.backgroundColor = UIColor.clearColor()
        return mediaControl
    }
    
    private func bindEventListeners() {
        for (event, callback) in eventBindings() {
            container.listenTo(self, eventName: event.rawValue, callback: callback)
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
            scrubberLeftConstraint.constant = delta
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
    
    private func setSubviewsVisibility(hidden hidden: Bool) {
        for subview in subviews {
            subview.hidden = hidden
        }
    }

    @IBAction func togglePlay(sender: UIButton) {
        if container.isPlaying {
            pause()
        } else {
            play()
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
    
    private func trigger(event: MediaControlEvent) {
        trigger(event.rawValue)
    }
}