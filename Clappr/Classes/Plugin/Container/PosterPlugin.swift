import Kingfisher

public class PosterPlugin: UIContainerPlugin {
    private var poster = UIImageView(frame: CGRectZero)
    private var playButton = UIButton(frame: CGRectZero)
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var pluginName: String {
        return "poster"
    }
    
    public required init() {
        super.init()
    }

    public required init(context: UIBaseObject) {
        super.init(context: context)
        translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .ScaleAspectFit
    }
    
    public override func render() {
        guard let urlString = container.options[kPosterUrl] as? String else {
            removeFromSuperview()
            container.mediaControlEnabled = true
            return
        }
        
        if let url = NSURL(string: urlString) {
            poster.kf_setImageWithURL(url)
        } else {
            Logger.logWarn("invalid URL.", scope: pluginName)
        }
        
        configurePlayButton()
        configureViews()
        bindEvents()
    }
    
    private func configurePlayButton() {
        let image = UIImage(named: "poster-play", inBundle: NSBundle(forClass: PosterPlugin.self),
            compatibleWithTraitCollection: nil)
        playButton.setBackgroundImage(image, forState: .Normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(PosterPlugin.playTouched), forControlEvents: .TouchUpInside)
    }
    
    func playTouched() {
        container.play()
    }
    
    private func configureViews() {
        container.addMatchingConstraints(self)
        addSubviewMatchingConstraints(poster)
        
        addSubview(playButton)
        
        let xCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .CenterX,
            relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .CenterY,
            relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        addConstraint(yCenterConstraint)
    }
    
    private func bindEvents() {
        for (event, callback) in eventsToBind() {
            listenTo(container, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func eventsToBind() -> [ContainerEvent : EventCallback] {
        return [
            .Buffering  : { [weak self] _ in self?.playbackBuffering() },
            .Play       : { [weak self] _ in self?.playbackStarted() },
            .Ended      : { [weak self] _ in self?.playbackEnded() },
            .Ready      : { [weak self] _ in self?.playbackReady() },
        ]
    }
    
    private func playbackBuffering() {
        playButton.hidden = true
    }
    
    private func playbackStarted() {
        hidden = true
        container.mediaControlEnabled = true
    }
    
    private func playbackEnded() {
        container.mediaControlEnabled = false
        playButton.hidden = false
        hidden = false
    }
    
    private func playbackReady() {
        if container.playback.pluginName == "NoOp" {
            hidden = true
        }
    }
}
