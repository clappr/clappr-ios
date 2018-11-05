open class PlayButton: MediaControlPlugin {
    override open var pluginName: String {
        return "PlayButton"
    }

    override open var panel: MediaControlPanel {
        return .center
    }

    override open var position: MediaControlPosition {
        return .center
    }

    public var playIcon = UIImage.fromName("play", for: PlayButton.self)!
    public var pauseIcon = UIImage.fromName("pause", for: PlayButton.self)!

    public var activeContainer: Container? {
        return core?.activeContainer
    }

    public var activePlayback: Playback? {
        return core?.activePlayback
    }

    public var button: UIButton! {
        didSet {
            view.addSubview(button)
            button.setImage(playIcon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            button.bindFrameToSuperviewBounds()
        }
    }

    required public init(context: UIObject) {
        super.init(context: context)
        bindEvents()
    }

    required public init() {
        super.init()
    }

    required public init?(coder argument: NSCoder) {
        super.init(coder: argument)
    }

    private func bindEvents() {
        stopListening()

        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    open func bindCoreEvents() {
        if let core = core {
            listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] _ in self?.bindEvents() }
        }
    }

    open func bindContainerEvents() {
        if let container = activeContainer {
            listenTo(container,
                     eventName: InternalEvent.didChangePlayback.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
        }
    }

    func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in self?.onPause() }
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.onPlay() }
            listenTo(playback, eventName: Event.stalled.rawValue) { [weak self] _ in self?.hide() }
        }
    }

    override open func render() {
        if let superview = view.superview {
            view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.6).isActive = true
            view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.6).isActive = true
        }

        button = UIButton(type: .custom)
        button.accessibilityIdentifier = "PlayPauseButton"
    }

    open func onPlay() {
        show()
        changeIcon()
    }

    private func onPause() {
        show()
        changeIcon()
    }

    public func hide() {
        view.isHidden = true
    }

    public func show() {
        view.isHidden = false
    }

    @objc func togglePlayPause() {
        guard let playback = activePlayback else {
            return
        }

        if playback.isPlaying {
            activePlayback?.pause()
        } else if playback.isPaused {
            activePlayback?.play()
        }
    }

    public func changeIcon() {
        guard let playback = activePlayback else {
            return
        }

        if playback.isPaused {
            button.setImage(playIcon, for: .normal)
        } else if playback.isPlaying {
            button.setImage(pauseIcon, for: .normal)
        }
    }
}
