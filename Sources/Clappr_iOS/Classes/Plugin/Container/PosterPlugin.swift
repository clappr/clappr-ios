open class PosterPlugin: OverlayPlugin {
    var poster = UIImageView(frame: CGRect.zero)
    fileprivate var playButton = UIButton(frame: CGRect.zero)
    private var isChromeless: Bool { core?.options.bool(kChromeless) ?? false }

    open override class var name: String {
        return "poster"
    }

    public required init(context: UIObject) {
        super.init(context: context)
        view.translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .scaleAspectFit
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
            core.activeContainer?.mediaControlEnabled = false
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
        activePlayback?.seek(0)
        activePlayback?.play()
    }

    fileprivate func configureViews() {
        core?.overlayView.addMatchingConstraints(view)
        view.addSubviewMatchingConstraints(poster)

        view.addSubview(playButton)

        let xCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerX,
                                                   relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        view.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerY,
                                                   relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraint(yCenterConstraint)
    }

    override open func bindEvents() {}

    override open func onDidChangeActiveContainer() {
        guard let container = activeContainer else { return }
        listenTo(container, eventName: Event.requestPosterUpdate.rawValue) { [weak self] info in self?.updatePoster(info) }
        listenTo(container, eventName: Event.didUpdateOptions.rawValue) { [weak self] _ in self?.updatePoster(container.options) }
    }

    override open func onDidChangePlayback() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.playbackStarted() }
            listenTo(playback, eventName: Event.stalling.rawValue) { [weak self] _ in self?.playbackStalled() }
            
            if playback is NoOpPlayback {
                view.isHidden = true
            }
        }
    }

    fileprivate func playbackStalled() {
        playButton.isHidden = true
    }

    fileprivate func playbackStarted() {
        view.isHidden = true
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
