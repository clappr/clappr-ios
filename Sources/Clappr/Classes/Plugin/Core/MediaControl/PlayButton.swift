class PlayButton: MediaControlPlugin {
    override var pluginName: String {
        return "PlayButton"
    }

    override var panel: MediaControlPanel {
        return .center
    }

    override var position: MediaControlPosition {
        return .center
    }

    open let playIcon = UIImage.fromName("play")!
    open let pauseIcon = UIImage.fromName("pause")!

    private var activeContainer: Container? {
        return core?.activeContainer
    }

    private var activePlayback: Playback? {
        return core?.activePlayback
    }

    private var isLive: Bool = false

    private var isDvrAvailable: Bool {
        return activePlayback?.isDvrAvailable ?? false
    }

    internal(set) var button: UIButton! {
        didSet {
            view.addSubview(button)
            button.setImage(playIcon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            button.bindFrameToSuperviewBounds()
        }
    }

    required init(context: UIBaseObject) {
        super.init(context: context)
        bindEvents()
    }

    required init() {
        super.init()
    }

    required init?(coder argument: NSCoder) {
        super.init(coder: argument)
    }

    private func bindEvents() {
        stopListening()

        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    private func bindCoreEvents() {
        if let core = core {
            listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] _ in self?.bindEvents() }
        }
    }

    private func bindContainerEvents() {
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

    override func render() {
        if let superview = view.superview {
            view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.6).isActive = true
            view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.6).isActive = true
        }

        button = UIButton(type: .custom)
        button.accessibilityIdentifier = "PlayPauseButton"
    }

    private func onPlay() {
        show()
        changeIcon()
    }

    private func onPause() {
        show()
        changeIcon()
    }

    private func hide() {
        view.isHidden = true
    }

    private func show() {
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

    private func changeIcon() {
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
