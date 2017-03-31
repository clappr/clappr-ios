open class LoadingContainerPlugin: UIContainerPlugin {
    
    fileprivate var spinningWheel: UIActivityIndicatorView!
    
    public required init() {
        super.init()
    }
    
    open override var pluginName: String {
        return "spinner"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(context: UIBaseObject) {
        super.init(context: context)
        self.spinningWheel = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        addSubview(spinningWheel)
        isUserInteractionEnabled = false
        bindDidChangePlayback()
    }
    
    private func bindDidChangePlayback() {
        listenTo(container, eventName: InternalEvent.didChangeActivePlayback.rawValue, callback: didChangePlayback)
    }
    
    private func didChangePlayback(_ userInfo: EventUserInfo) {
        stopListening()
        bindPlaybackEvents()
        bindDidChangePlayback()
    }
    
    override open func render() {
        addCenteringConstraints()
    }
    
    fileprivate func addCenteringConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: spinningWheel.frame.width)
        addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: spinningWheel.frame.height)
        addConstraint(heightConstraint)
        
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX,
            relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
        container.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY,
            relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
        container.addConstraint(yCenterConstraint)
    }

    private func bindPlaybackEvents() {
        if let playback = container.playback {
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
            listenTo(playback, eventName: Event.stalled.rawValue) { [weak self] (info: EventUserInfo) in self?.startAnimating(info) }
            listenTo(playback, eventName: Event.error.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
        }
    }

    fileprivate func startAnimating(_ userInfo: EventUserInfo) {
        spinningWheel.startAnimating()
        Logger.logDebug("started animating spinning wheel", scope: self.pluginName)
    }

    fileprivate func stopAnimating(_ userInfo: EventUserInfo) {
        spinningWheel.stopAnimating()
        Logger.logDebug("stoped animating spinning wheel", scope: self.pluginName)
    }
}
