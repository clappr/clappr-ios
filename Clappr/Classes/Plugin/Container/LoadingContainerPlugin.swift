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
    }

    override open func render() {
        addCenteringConstraints()
        bindEventListeners()
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

    fileprivate func bindEventListeners() {
        listenTo(container, eventName: ContainerEvent.buffering.rawValue, callback: startAnimating)
        listenTo(container, eventName: ContainerEvent.play.rawValue, callback: stopAnimating)
        listenTo(container, eventName: ContainerEvent.ended.rawValue, callback: stopAnimating)
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
