public class LoadingContainerPlugin: UIContainerPlugin {
    
    private var spinningWheel: UIActivityIndicatorView
    
    public required init() {
        spinningWheel = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        super.init()
        addSubview(spinningWheel)
        userInteractionEnabled = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func wasInstalled() {
        super.wasInstalled()
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
            relatedBy: .Equal, toItem: container!, attribute: .CenterX, multiplier: 1, constant: 0)
        container!.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .CenterY,
            relatedBy: .Equal, toItem: container!, attribute: .CenterY, multiplier: 1, constant: 0)
        container!.addConstraint(yCenterConstraint)
    }
    
    private func bindEventListeners() {
        listenTo(container!, eventName: ContainerEvent.Buffering.rawValue) {[weak self] _ in
            self?.spinningWheel.startAnimating()
        }
        
        listenTo(container!, eventName: ContainerEvent.Play.rawValue, callback: stopAnimating)
        listenTo(container!, eventName: ContainerEvent.Ended.rawValue, callback: stopAnimating)
    }
    
    private func stopAnimating(userInfo: EventUserInfo) {
        spinningWheel.stopAnimating()
    }
}