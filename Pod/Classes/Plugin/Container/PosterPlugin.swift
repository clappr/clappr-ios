import Haneke

public class PosterPlugin: UIContainerPlugin {
    private var poster = UIImageView(frame: CGRectZero)
    private var playButton = UIButton(frame: CGRectZero)
    private var url: NSURL!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var pluginName: String {
        return "poster"
    }
    
    public required init() {
        super.init()
        translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .ScaleAspectFit
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        poster.hnk_setImageFromURL(url)
    }
    
    public override func wasInstalled() {
        guard let urlString = container!.options[kPosterUrl] as? String else {
            removeFromSuperview()
            container!.mediaControlEnabled = true
            return
        }
        
        url = NSURL(string: urlString)!
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
        container!.play()
        playButton.hidden = true
    }
    
    private func configureViews() {
        container!.addMatchingConstraints(self)
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
            listenTo(container!, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func eventsToBind() -> [ContainerEvent : EventCallback] {
        return [
            .Play  : { [weak self] _ in self?.playbackStarted() },
            .Ended : { [weak self] _ in self?.playbackEnded() },
        ]
    }
    
    private func playbackStarted() {
        hidden = true
        container!.mediaControlEnabled = true
    }
    
    private func playbackEnded() {
        container!.mediaControlEnabled = false
        playButton.hidden = false
        hidden = false
    }
}