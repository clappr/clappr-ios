public class LoadingContainerPlugin: UIContainerPlugin {
    
    private var spinningWheel: UIActivityIndicatorView
    
    public init() {
        spinningWheel = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        spinningWheel.startAnimating()
        super.init(frame: CGRectZero)
        addSubview(spinningWheel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func wasIntalled() {
        super.wasIntalled()
        addCenteringConstraints()
        bindEventListeners()
    }
    
    private func addCenteringConstraints() {
        spinningWheel.translatesAutoresizingMaskIntoConstraints = false
        
        let xCenterConstraint = NSLayoutConstraint(item: spinningWheel, attribute: .CenterX,
            relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: spinningWheel, attribute: .CenterY,
            relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        addConstraint(yCenterConstraint)
    }
    
    private func bindEventListeners() {
        listenTo(container!, eventName: ContainerEvent.Buffering.rawValue) {[weak self] _ in
            self?.spinningWheel.startAnimating()
        }
        
        listenTo(container!, eventName: ContainerEvent.Play.rawValue) {[weak self] _ in
            self?.spinningWheel.stopAnimating()
        }
    }
}