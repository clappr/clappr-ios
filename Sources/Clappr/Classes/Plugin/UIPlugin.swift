open class UIPlugin: UIBaseObject, UIObject {
    @objc open var view: UIView
    
    public override init(frame: CGRect) {
        self.view = UIView()
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
