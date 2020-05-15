open class PlayButton: MediaControl.Element {
    open class override var name: String { "PlayButton" }

    override open var panel: MediaControlPanel { .center}
    override open var position: MediaControlPosition { .center }

    public var playIcon = UIImage.fromName("play", for: PlayButton.self)!
    public var pauseIcon = UIImage.fromName("pause", for: PlayButton.self)!

    public var button: UIButton? {
        didSet {
            guard let button = button else { return }

            view.addSubview(button)
            button.setImage(playIcon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            button.bindFrameToSuperviewBounds()
        }
    }

    private var canShowPlayIcon: Bool {
        activePlayback?.state == .paused || activePlayback?.state == .idle
    }

    private var canShowPauseIcon: Bool {
        activePlayback?.state == .playing
    }

    override open func bindEvents() {
        bindPlaybackEvents()
    }

    func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in self?.onPause() }
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.onPlay() }
            listenTo(playback, eventName: Event.stalling.rawValue) { [weak self] _ in self?.hide() }
            listenTo(playback, eventName: Event.didStop.rawValue) { [weak self] _ in self?.onStop() }
        }
    }

    override open func render() {
        setupView()
        setupButton()
    }

    private func setupView() {
        guard let superview = view.superview else { return }

        view.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.6).isActive = true
        view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.6).isActive = true
    }

    private func setupButton() {
        button = UIButton(type: .custom)
        button?.accessibilityIdentifier = "PlayPauseButton"
    }

    open func onPlay() {
        show()
        changeToPauseIcon()
    }

    private func onPause() {
        show()
        changeToPlayIcon()
    }

    private func onStop() {
        show()
        changeToPlayIcon()
    }
    
    public func hide() {
        view.isHidden = true
    }

    public func show() {
        view.isHidden = false
    }
    
    @objc func togglePlayPause() {
        guard let playback = activePlayback else { return }
        
        switch playback.state {
        case .playing:
            pause()
        case .paused, .idle:
            play()
        default:
            break
        }
    }

    private func pause() {
        activePlayback?.pause()
    }

    private func play() {
        activePlayback?.play()
    }
    
    private func changeToPlayIcon() {
        guard canShowPlayIcon else { return }

        button?.setImage(playIcon, for: .normal)
    }

    public func changeToPauseIcon() {
        guard canShowPauseIcon else { return }

        button?.setImage(pauseIcon, for: .normal)
    }
}
