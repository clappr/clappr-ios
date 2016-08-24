public class LoadingContainerPlugin: UIContainerPlugin {
    
    private var spinningWheel: UIActivityIndicatorView!
    
    public required init() {
        super.init()
    }
    
    public override var pluginName: String {
        return "spinner"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init(context: UIBaseObject) {
        super.init(context: context)
        self.spinningWheel = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        addSubview(spinningWheel)
        userInteractionEnabled = false
    }

    override public func render() {
        addCenteringConstraints()
        bindEventListeners()
    }
    
    private func addCenteringConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: spinningWheel.frame.width)
        addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: spinningWheel.frame.height)
        addConstraint(heightConstraint)
        
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .CenterX,
            relatedBy: .Equal, toItem: container, attribute: .CenterX, multiplier: 1, constant: 0)
        container.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .CenterY,
            relatedBy: .Equal, toItem: container, attribute: .CenterY, multiplier: 1, constant: 0)
        container.addConstraint(yCenterConstraint)
    }
    
    private func bindEventListeners() {
        listenTo(container, eventName: ContainerEvent.Buffering.rawValue) {[weak self] _ in
            self?.spinningWheel.startAnimating()
            Logger.logDebug("Started animating spinning wheel", scope: "\(self?.dynamicType)")
        }
        
        listenTo(container, eventName: ContainerEvent.Play.rawValue, callback: stopAnimating)
        listenTo(container, eventName: ContainerEvent.Ended.rawValue, callback: stopAnimating)
    }
    
    private func stopAnimating(userInfo: EventUserInfo) {
        spinningWheel.stopAnimating()
        Logger.logDebug("Stoped animating spinning wheel", scope: "\(self.dynamicType)")
    }
}