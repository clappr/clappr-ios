open class PosterPlugin: OverlayPlugin {
    
    private var poster = UIImageView(frame: CGRect.zero)
    private var playButton = UIButton(frame: CGRect.zero)
    private var isChromeless: Bool { core?.options.bool(kChromeless) ?? false }

    open override class var name: String {
        return "poster"
    }

    open override func render() {
        guard let core = core else { return }
        
        if isChromeless {
            view.isHidden = true
        }
        
        if let urlString = core.options[kPosterUrl] as? String {
            setPosterImage(with: urlString)
        } else {
            view.isHidden = true
            activeContainer?.mediaControlEnabled = false
        }

        configurePlayButton()
        configureContraints()
    }

    private func setPosterImage(with urlString: String) {
        if let url = URL(string: urlString) {
            poster.setImage(from: url)
            poster.contentMode = .scaleAspectFit
        } else {
            Logger.logWarn("invalid URL.", scope: pluginName)
        }
    }

    private func configurePlayButton() {
        let image = UIImage(named: "poster-play", in: Bundle(for: PosterPlugin.self),
                            compatibleWith: nil)
        playButton.setBackgroundImage(image, for: UIControl.State())
        playButton.addTarget(self, action: #selector(PosterPlugin.playTouched), for: .touchUpInside)
    }

    @objc func playTouched() {
        activePlayback?.seek(0)
        activePlayback?.play()
    }

    private func configureContraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        poster.translatesAutoresizingMaskIntoConstraints = false
        
        core?.overlayView.addMatchingConstraints(view)
        view.addSubviewMatchingConstraints(poster)

        view.addSubview(playButton)
        playButton.anchorInCenter()
    }

    override open func bindEvents() {}

    override open func onDidChangeActiveContainer() {
        guard let container = activeContainer else { return }
        
        listenTo(container, event: .requestPosterUpdate) { [weak self] info in self?.updatePoster(info) }
        listenTo(container, event: .didUpdateOptions) { [weak self] _ in self?.updatePoster(container.options) }
    }

    override open func onDidChangePlayback() {
        guard let playback = activePlayback else { return }
        
        listenTo(playback, event: .playing) { [weak self] _ in self?.playbackStarted() }
        listenTo(playback, event: .stalling) { [weak self] _ in self?.playbackStalled() }
        
        if playback is NoOpPlayback {
            view.isHidden = true
        }
    }

    private func playbackStalled() {
        playButton.isHidden = true
    }

    private func playbackStarted() {
        view.isHidden = true
    }
    
    private func updatePoster(_ info: EventUserInfo) {
        Logger.logInfo("Updating poster", scope: pluginName)
        guard let posterUrl = info?[kPosterUrl] as? String else {
            Logger.logWarn("Unable to update poster, no url was found", scope: pluginName)
            return
        }
        trigger(Event.willUpdatePoster)
        setPosterImage(with: posterUrl)
        trigger(Event.didUpdatePoster)
    }
}
