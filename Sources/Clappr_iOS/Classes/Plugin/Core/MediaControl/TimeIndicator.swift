open class TimeIndicator: MediaControl.Element {
    open class override var name: String {
        return "TimeIndicator"
    }

    override open var panel: MediaControlPanel {
        return .bottom
    }

    override open var position: MediaControlPosition {
        return .left
    }

    public var indicator: UIStackView! {
        didSet {
            view.addSubview(indicator)
            indicator.accessibilityIdentifier = "timeIndicator"
        }
    }

    open var leftMarginSize: NSLayoutConstraint?
    var leftMargin: UIView! {
        didSet {
            indicator.addArrangedSubview(leftMargin)
            leftMarginSize = leftMargin.widthAnchor.constraint(equalToConstant: 0)
            leftMarginSize?.priority = UILayoutPriority.defaultLow
            leftMarginSize?.isActive = true
            leftMarginSize?.identifier = "$leftMarginSize$"
        }
    }

    open var elapsedTimeLabel: UILabel! {
        didSet {
            indicator.addArrangedSubview(elapsedTimeLabel)
            elapsedTimeLabel.accessibilityIdentifier = "elapsedTime"
            elapsedTimeLabel.textColor = .white
            elapsedTimeLabel.font = UIFont.boldSystemFont(ofSize: 14)
            elapsedTimeLabel.text = "00:00"
        }
    }

    open var separatorLabel: UILabel! {
        didSet {
            indicator.addArrangedSubview(separatorLabel)
            separatorLabel.textColor = .white
            separatorLabel.font = UIFont.boldSystemFont(ofSize: 14)
            separatorLabel.text = " / "
        }
    }

    open var durationTimeLabel: UILabel! {
        didSet {
            indicator.addArrangedSubview(durationTimeLabel)
            durationTimeLabel.textColor = .white
            durationTimeLabel.font = UIFont.boldSystemFont(ofSize: 14)
            durationTimeLabel.text = "00:00"
        }
    }

    override open func bindEvents() {
        bindPlaybackEvents()
        bindCoreEvents()
    }

    private func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.didUpdateDuration.rawValue) { [weak self] (info: EventUserInfo) in self?.displayVideoDuration(info) }
            listenTo(playback, eventName: Event.didUpdatePosition.rawValue) { [weak self] (info: EventUserInfo) in self?.updateElapsedTime(info) }
        }
    }

    private func bindCoreEvents() {
        if let core = self.core {
            listenTo(core, eventName: Event.didEnterFullscreen.rawValue) { [weak self] _ in self?.updateLayoutConstants() }
            listenTo(core, eventName: Event.didExitFullscreen.rawValue) { [weak self] _ in self?.updateLayoutConstants() }
        }
    }

    open func displayVideoDuration(_ info: EventUserInfo) {
        guard let duration = info?["duration"] as? Double else { return }
        durationTimeLabel?.text = ClapprDateFormatter.formatSeconds(duration)
        view.isHidden = false
    }

    private func updateElapsedTime(_ info: EventUserInfo) {
        guard let position = info?["position"] as? TimeInterval else { return }
        elapsedTimeLabel?.text = ClapprDateFormatter.formatSeconds(position)
    }

    override open func render() {
        view.isHidden = true
        indicator = UIStackView()
        leftMargin = UIView()
        elapsedTimeLabel = UILabel()
        separatorLabel = UILabel()
        durationTimeLabel = UILabel()
        updateLayoutConstants()
    }

    open var marginBottom: CGFloat = 0 {
        didSet {
            indicator.bindFrameToSuperviewBounds(with: UIEdgeInsets(top: 0,
                                                                    left: 0,
                                                                    bottom: marginBottom,
                                                                    right: 0),
                                                 identifier: "$marginBottom$")
        }
    }

    open func updateLayoutConstants() {
        guard let marginBottomConstant = layoutConstants["marginBottom"] else { return }
        guard let marginLeftConstant = layoutConstants["leftMargin"] else { return }

        view.removeConstraints(view.constraints)

        marginBottom = marginBottomConstant
        leftMarginSize?.constant = marginLeftConstant
    }

    private var layoutConstants: [String: CGFloat] = [
        "marginBottom": 10,
        "leftMargin": 16
    ]
}
