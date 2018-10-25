open class TimeIndicator: MediaControlPlugin {
    override open var pluginName: String {
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

    var leftMarginSize: NSLayoutConstraint?
    var leftMargin: UIView! {
        didSet {
            indicator.addArrangedSubview(leftMargin)
            leftMarginSize = leftMargin.widthAnchor.constraint(equalToConstant: 0)
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

    public var activeContainer: Container? {
        return core?.activeContainer
    }

    public var activePlayback: Playback? {
        return core?.activePlayback
    }

    required public init(context: UIBaseObject) {
        super.init(context: context)
        stopListening()
        bindEvents()
    }

    required public init() {
        super.init()
    }

    required public init?(coder argument: NSCoder) {
        super.init(coder: argument)
    }

    private func bindEvents() {
        bindContainerEvents()
        bindPlaybackEvents()
        bindCoreEvents()
    }

    private func bindContainerEvents() {
        if let container = activeContainer {
            listenTo(container, eventName: InternalEvent.didChangePlayback.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
        }
    }

    private func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in self?.displayVideoDuration() }
            listenTo(playback, eventName: Event.positionUpdate.rawValue) { [weak self] (info: EventUserInfo) in self?.updateElapsedTime(info) }
        }
    }

    private func bindCoreEvents() {
        if let core = self.core {
            listenTo(core, eventName: InternalEvent.didEnterFullscreen.rawValue) { [weak self] _ in self?.updateLayoutConstants() }
            listenTo(core, eventName: InternalEvent.didExitFullscreen.rawValue) { [weak self] _ in self?.updateLayoutConstants() }
            listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
        }
    }

    open func displayVideoDuration() {
        durationTimeLabel?.text = ClapprDateFormatter.formatSeconds(activePlayback?.duration ?? 0.0)
        view.isHidden = false
    }

    private func updateElapsedTime(_ info: EventUserInfo) {
        guard let position = info!["position"] as? TimeInterval else { return }
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

    var marginBottom: CGFloat = 0 {
        didSet {
            indicator.bindFrameToSuperviewBounds(with: UIEdgeInsets(top: 0,
                                                                    left: 0,
                                                                    bottom: marginBottom,
                                                                    right: 0),
                                                 identifier: "$marginBottom$")
        }
    }

    private func updateLayoutConstants() {
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
