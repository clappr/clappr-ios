protocol SeekbarDelegate: NSObjectProtocol {
    func seek(_: TimeInterval)
    func willBeginScrubbing()
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
            isLive ? setupLiveStyle() : setupVODStyle()
        }
    }

    var videoDuration: CGFloat = 0
    private(set) var isSeeking = false
    private(set) var previousSeekbarWidth: CGFloat = 0

    weak var delegate: SeekbarDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        isLive ? putScrubberAtTheEnd() : repositionUIElements()
        previousSeekbarWidth = seekBarContainerView.frame.width
    }

    @objc func handleSeekbarViewTouch(_ view: DragDetectorView) {
        guard let touchPoint = view.currentTouch?.location(in: seekBarContainerView) else { return }

        moveScrubber(relativeTo: touchPoint.x)

        switch view.touchState {
        case .began, .moved, .idle:
            delegate?.willBeginScrubbing()
            isSeeking = true
            setOuterScrubberSize(outerCircleSizeFactor: 1.5, outerCircleBorderWidth: 1.0)
        case .ended, .canceled:
            delegate?.seek(seconds(relativeTo: scrubberPosition.constant))
            delegate?.didFinishScrubbing()
            isSeeking = false
            setOuterScrubberSize(outerCircleSizeFactor: 1.0, outerCircleBorderWidth: 0.0)
        }
    }

    func updateScrubber(time: CGFloat) {
        guard videoDuration > 0, !isLive else { return }

        let position = (time / videoDuration) * (seekBarContainerView.frame.width)
        moveScrubber(relativeTo: position)
    }

    private func moveScrubber(relativeTo position: CGFloat) {
        let halfScrubberWidth = scrubber.frame.width / 2
        let minBoundPosition =  -halfScrubberWidth
        let maxBoundPosition = seekBarContainerView.frame.width - halfScrubberWidth

        var axisScrubberPosition = position - halfScrubberWidth
        if axisScrubberPosition <= minBoundPosition {
            axisScrubberPosition = minBoundPosition
        } else if axisScrubberPosition > maxBoundPosition {
            axisScrubberPosition = maxBoundPosition
        }

        scrubberPosition.constant = axisScrubberPosition
        progressBarWidthConstraint?.constant = axisScrubberPosition + halfScrubberWidth
        updateTimeLabel(relativeTo: scrubberPosition.constant)
        moveTimeLabel(relativeTo: position, state: .moved)
    }
    
    func moveTimeLabel(relativeTo horizontalTouchPoint: CGFloat, state: DragDetectorView.State) {
        if state == .moved {
            timeLabelView.isHidden = false
            let halfTimeLabelView: CGFloat = timeLabelView.frame.width / 2

            var position = horizontalTouchPoint - halfTimeLabelView
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
        guard videoDuration > 0 else { return }
        bufferWidth.constant = (time / videoDuration) * seekBarContainerView.frame.width
    }

    private func setOuterScrubberSize(outerCircleSizeFactor: CGFloat, outerCircleBorderWidth: CGFloat) {
        scrubberOuterCircleHeightConstraint?.constant = scrubber.frame.height * outerCircleSizeFactor
        scrubberOuterCircleWidthConstraint?.constant = scrubber.frame.width * outerCircleSizeFactor
        scrubberOuterCircle?.layer.cornerRadius = scrubber.frame.width * outerCircleSizeFactor / 2
        scrubberOuterCircle?.layer.borderWidth = outerCircleBorderWidth
    }
    
    private func seconds(relativeTo scrubberPosition: CGFloat) -> Double {
        let width = seekBarContainerView.frame.width
        let positionPercentage = max(0, min((scrubberPosition + scrubber.frame.width / 2) / width, 1))
        return Double(videoDuration * positionPercentage)
    }

    fileprivate func repositionScrubber() {
        let halfScrubber = scrubber.frame.width / 2
        let previousPercentPosition = (scrubberPosition.constant + halfScrubber) / previousSeekbarWidth
        let newPercentPosition = previousPercentPosition * seekBarContainerView.frame.width
        moveScrubber(relativeTo: newPercentPosition)
    }

    fileprivate func redimentionBufferBar() {
        let previousPercentPosition = bufferWidth.constant / previousSeekbarWidth
        let newPercentPosition = previousPercentPosition * seekBarContainerView.frame.width
        bufferWidth.constant = newPercentPosition
    }

    private func repositionUIElements() {
        guard previousSeekbarWidth > 0 else { return }

        repositionScrubber()
        redimentionBufferBar()
    }

    private func setupLiveStyle() {
        progressBar.backgroundColor = .red
        bufferBar.isHidden = true
        timeLabelView.isHidden = true
        timeLabel.isHidden = true
        putScrubberAtTheEnd()
        isUserInteractionEnabled = false
    }

    private func putScrubberAtTheEnd() {
        scrubberPosition.constant = seekBarContainerView.frame.width - scrubber.frame.width / 2
        progressBarWidthConstraint?.constant = seekBarContainerView.frame.width
    }

    private func setupVODStyle() {
        progressBar.backgroundColor = .blue
        timeLabelView.isHidden = false
        timeLabel.isHidden = false
        bufferBar.isHidden = false
        bufferBar.backgroundColor = .gray
        isUserInteractionEnabled = true
    }
}
