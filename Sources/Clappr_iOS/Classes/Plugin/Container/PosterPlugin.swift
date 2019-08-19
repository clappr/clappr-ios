open class PosterPlugin: UIContainerPlugin {
    var poster = UIImageView(frame: CGRect.zero)
    fileprivate var playButton = UIButton(frame: CGRect.zero)

    open override class var name: String {
        return "poster"
    }

    public required init(context: UIObject) {
        super.init(context: context)
        view.translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .scaleAspectFit
    }

    open override func render() {
        guard let container = container else { return }
        if let urlString = container.options[kPosterUrl] as? String {
            setPosterImage(with: urlString)
        } else {
            view.isHidden = true
            container.mediaControlEnabled = false
        }

        configurePlayButton()
        configureViews()
    }

    fileprivate typealias PosterUrl = String
    fileprivate func setPosterImage(with urlString: PosterUrl) {
        if let url = URL(string: urlString) {
            poster.setImage(from: url)
        } else {
            Logger.logWarn("invalid URL.", scope: pluginName)
        }
    }

    fileprivate func configurePlayButton() {
        let image = UIImage(named: "poster-play", in: Bundle(for: PosterPlugin.self),
                            compatibleWith: nil)
        playButton.setBackgroundImage(image, for: UIControl.State())
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(PosterPlugin.playTouched), for: .touchUpInside)
    }

    @objc func playTouched() {
        playback?.seek(0)
        playback?.play()
    }

    fileprivate func configureViews() {
        container?.view.addMatchingConstraints(view)
        view.addSubviewMatchingConstraints(poster)

        view.addSubview(playButton)

        let xCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerX,
                                                   relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerY,
                                                   relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(yCenterConstraint)
    }

    override open func bindEvents() {
        bindContainerEvents()
        bindPlaybackEvents()
    }

    private func bindPlaybackEvents() {
        if let playback = playback {
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.playbackStarted() }
            listenTo(playback, eventName: Event.stalling.rawValue) { [weak self] _ in self?.playbackStalled() }
            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in self?.playbackEnded() }
        }
    }

    private func bindContainerEvents() {
        guard let container = container else { return }
        listenTo(container, eventName: Event.requestPosterUpdate.rawValue) { [weak self] info in self?.updatePoster(info) }
        listenTo(container, eventName: Event.didUpdateOptions.rawValue) { [weak self] _ in self?.updatePoster(container.options) }
    }

    override open func onDidChangePlayback() {
        if isNoOpPlayback {
            view.isHidden = true
        }
    }

    fileprivate func playbackStalled() {
        playButton.isHidden = true
    }

    fileprivate func playbackStarted() {
        view.isHidden = true
    }

    fileprivate func playbackEnded() {
        container?.mediaControlEnabled = false
        playButton.isHidden = false
        view.isHidden = false
    }

    fileprivate func updatePoster(_ info: EventUserInfo) {
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
