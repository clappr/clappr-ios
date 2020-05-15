open class PlayButton: MediaControl.Element {
    open class override var name: String {
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

    public var button: UIButton! {
        didSet {
            view.addSubview(button)
            button.setImage(playIcon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
            button.bindFrameToSuperviewBounds()
        }
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

    private func onStop() {
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

        if playback.state == .playing {
            activePlayback?.pause()
        } else if playback.state == .paused || playback.state == .idle {
            activePlayback?.play()
        }
    }

    public func changeIcon() {
        guard let playback = activePlayback else {
            return
        }

        if playback.state == .paused || playback.state == .idle {
            button.setImage(playIcon, for: .normal)
        } else if playback.state == .playing {
            button.setImage(pauseIcon, for: .normal)
        }
    }
}
