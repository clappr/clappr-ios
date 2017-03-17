import Kingfisher

open class PosterPlugin: UIContainerPlugin {
    fileprivate var poster = UIImageView(frame: CGRect.zero)
    fileprivate var playButton = UIButton(frame: CGRect.zero)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var pluginName: String {
        return "poster"
    }
    
    public required init() {
        super.init()
    }

    public required init(context: UIBaseObject) {
        super.init(context: context)
        translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .scaleAspectFit
    }
    
    open override func render() {
        guard let urlString = container.options[kPosterUrl] as? String else {
            removeFromSuperview()
            container.mediaControlEnabled = true
            return
        }
        
        if let url = URL(string: urlString) {
            poster.kf.setImage(with: url)
        } else {
            Logger.logWarn("invalid URL.", scope: pluginName)
        }
        
        configurePlayButton()
        configureViews()
        bindEvents()
    }
    
    fileprivate func configurePlayButton() {
        let image = UIImage(named: "poster-play", in: Bundle(for: PosterPlugin.self),
            compatibleWith: nil)
        playButton.setBackgroundImage(image, for: UIControlState())
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(PosterPlugin.playTouched), for: .touchUpInside)
    }
    
    func playTouched() {
        container.seek(0)
        container.play()
    }
    
    fileprivate func configureViews() {
        container.addMatchingConstraints(self)
        addSubviewMatchingConstraints(poster)
        
        addSubview(playButton)
        
        let xCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerX,
            relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerY,
            relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addConstraint(yCenterConstraint)
    }
    
    fileprivate func bindEvents() {
        for (event, callback) in eventsToBind() {
            listenTo(container, eventName: event.rawValue, callback: callback)
        }
    }
    
    fileprivate func eventsToBind() -> [ContainerEvent : EventCallback] {
        return [
            .buffering  : { [weak self] _ in self?.playbackBuffering() },
            .play       : { [weak self] _ in self?.playbackStarted() },
            .ended      : { [weak self] _ in self?.playbackEnded() },
            .ready      : { [weak self] _ in self?.playbackReady() },
        ]
    }
    
    fileprivate func playbackBuffering() {
        playButton.isHidden = true
    }
    
    fileprivate func playbackStarted() {
        isHidden = true
        container.mediaControlEnabled = true
    }
    
    fileprivate func playbackEnded() {
        container.mediaControlEnabled = false
        playButton.isHidden = false
        isHidden = false
    }
    
    fileprivate func playbackReady() {
        if container.playback.pluginName == "NoOp" {
            isHidden = true
        }
    }
}
