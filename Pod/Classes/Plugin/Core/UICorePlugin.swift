public class UICorePlugin: UIPlugin {
    public private(set) weak var core: Core?
    
    public required init(core: Core) {
        self.core = core
        super.init(frame: CGRectZero)
        core.addSubview(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(core: Core) instead")
    }
}