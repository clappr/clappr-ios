protocol SeekbarDelegate: NSObjectProtocol {
    func seek(_: TimeInterval)
    func willBeginScrubbing()
    func isScrubbing(scrubberFrame: CGRect, currentSecond: Int)
    func didFinishScrubbing()
}

class SeekbarView: UIView {
    @IBOutlet weak var seekBarContainerView: DragDetectorView! {
        didSet {
            seekBarContainerView.target = self
            seekBarContainerView.selector = #selector(handleSeekbarViewTouch(_:))
        }
    }
    @IBOutlet weak var scrubberPosition: NSLayoutConstraint!
    @IBOutlet weak var scrubber: UIView! {
        didSet {
            scrubber.accessibilityIdentifier = "scrubber"
        }
    }
    @IBOutlet weak var scrubberOuterCircle: UIView?
    @IBOutlet weak var bufferBar: UIView!
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var timeLabelView: UIView! {
        didSet {
            timeLabelView.isHidden = true
        }
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeLabelPosition: NSLayoutConstraint!
    @IBOutlet weak var bufferWidth: NSLayoutConstraint!
    
    @IBOutlet open var scrubberOuterCircleWidthConstraint: NSLayoutConstraint?
    @IBOutlet open var scrubberOuterCircleHeightConstraint: NSLayoutConstraint?

    @IBOutlet open var progressBarWidthConstraint: NSLayoutConstraint?
    
    var isLive = false {
        didSet {
            setupStyle()
        }
    }

    var seekbarWidth: CGFloat = 0
    var videoDuration: CGFloat = 0
    var isSeeking = false
    var scrubberInitialWidth: CGFloat = 0.0
    var scrubberInitialHeight: CGFloat = 0.0
    
    weak var delegate: SeekbarDelegate?

    var isOfflineVideo = false

    @objc func handleSeekbarViewTouch(_ view: DragDetectorView) {
        guard let touch = view.currentTouch else { return }

        let touchPoint = touch.location(in: seekBarContainerView)
        moveScrubber(relativeTo: touchPoint.x)
        seeking(relativeTo: scrubberPosition.constant, state: view.touchState)
        adjustScrubberConstraints()

        if isOfflineVideo {
            moveTimeLabel(relativeTo: touchPoint.x, state: view.touchState)
            updateTimeLabel(relativeTo: scrubberPosition.constant)
        }
    }

    func updateScrubber(time: CGFloat) {
        if !isSeeking && videoDuration > 0 {
            var position = (time / videoDuration) * (seekBarContainerView.frame.width - scrubber.frame.width)
            if position > seekBarContainerView.frame.width - scrubber.frame.width {
                position = seekBarContainerView.frame.width - scrubber.frame.width
            } else if position < 0 {
                position = 0
            }
            scrubberPosition.constant = position
            progressBarWidthConstraint?.constant = position + scrubber.frame.width / 2
        }
    }

    private func moveScrubber(relativeTo horizontalTouchPoint: CGFloat) {
        var position = horizontalTouchPoint - (scrubber.frame.width / 2)
        if position <= 0 {
            position = 0
        } else if position > seekBarContainerView.frame.width - scrubber.frame.width {
            position = seekBarContainerView.frame.width - scrubber.frame.width
        }
        scrubberPosition.constant = position
        progressBarWidthConstraint?.constant = position + scrubber.frame.width / 2
    }
    
    private func moveTimeLabel(relativeTo horizontalTouchPoint: CGFloat, state: DragDetectorView.State) {
        if state == .moved {
            timeLabelView.isHidden = false
            var position = scrubberPosition.constant - timeLabelView.frame.width / 2 + scrubber.frame.width / 2
            if position <= 0 {
                position = 0
            } else if position > seekBarContainerView.frame.width - timeLabelView.frame.width {
                position = seekBarContainerView.frame.width - timeLabelView.frame.width
            }
            timeLabelPosition.constant = position
        } else {
            timeLabelView.isHidden = true
        }
    }

    private func updateTimeLabel(relativeTo horizontalTouchPoint: CGFloat) {
        let secs = seconds(relativeTo: horizontalTouchPoint)
        timeLabel.text = ClapprDateFormatter.formatSeconds(secs)
    }

    func updateBuffer(time: CGFloat) {
        if videoDuration > 0 {
            bufferWidth.constant = (time / videoDuration) * seekBarContainerView.frame.width
        }
    }

    private func seeking(relativeTo scrubberPosition: CGFloat, state: DragDetectorView.State) {
        switch state {
        case .began:
            delegate?.willBeginScrubbing()
        case .ended:
            delegate?.seek(seconds(relativeTo: scrubberPosition))
            delegate?.didFinishScrubbing()
            isSeeking = false
        case .canceled:
            delegate?.didFinishScrubbing()
            isSeeking = false
        default:
            delegate?.isScrubbing(scrubberFrame: scrubber.frame, currentSecond: Int(seconds(relativeTo: scrubberPosition)))
            isSeeking = true
        }
    }

    private func adjustScrubberConstraints() {
        scrubberOuterCircleHeightConstraint?.constant = isSeeking ? scrubberInitialHeight * 1.5 : scrubberInitialHeight
        scrubberOuterCircleWidthConstraint?.constant = isSeeking ? scrubberInitialWidth * 1.5 : scrubberInitialWidth
        scrubberOuterCircle?.layer.cornerRadius = isSeeking ? scrubberInitialWidth * 1.5 / 2 : scrubberInitialWidth / 2
        scrubberOuterCircle?.layer.borderWidth = isSeeking ? 1.0 : 0
    }
    
    private func seconds(relativeTo scrubberPosition: CGFloat) -> Double {
        let width = seekBarContainerView.frame.width - scrubber.frame.width
        let positionPercentage = max(0, min(scrubberPosition / width, 1))
        return Double(videoDuration * positionPercentage)
    }

    private func repositionScrubber() {
        if seekbarWidth > 0 {
            let position = (scrubberPosition.constant * (seekBarContainerView.frame.width - scrubber.frame.width)) / (seekbarWidth - scrubber.frame.width)
            scrubberPosition.constant = position
        }
    }

    private func repositionBuffer() {
        if seekbarWidth > 0 {
            let position = (bufferWidth.constant * seekBarContainerView.frame.width) / seekbarWidth
            bufferWidth.constant = position
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isLive {
            putScrubberAtTheEnd()
        } else {
            repositionScrubber()
            repositionBuffer()
        }

        seekbarWidth = seekBarContainerView.frame.width

        scrubberInitialWidth = scrubberOuterCircleWidthConstraint?.constant ?? 0
        scrubberInitialHeight = scrubberOuterCircleHeightConstraint?.constant ?? 0
    }

    private func setupStyle() {
        if !isLive {
            setupWhiteStyle()
        } else {
            setupRedStyle()
        }
    }

    private func setupRedStyle() {
        scrubber.backgroundColor = .red
        progressBar.backgroundColor = .red
        bufferBar.isHidden = true
        putScrubberAtTheEnd()
        isUserInteractionEnabled = false
    }

    private func putScrubberAtTheEnd() {
        scrubberPosition.constant = seekBarContainerView.frame.width - scrubber.frame.width
    }

    private func setupWhiteStyle() {
        scrubber.backgroundColor = .white
        progressBar.backgroundColor = .white
        bufferBar.isHidden = false
        isUserInteractionEnabled = true
    }
}
