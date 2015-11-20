public class Core: UIBaseObject {
    public private(set) var sources:[NSURL]
    
    public required init(sources: [NSURL]) {
        self.sources = sources
        super.init(frame: CGRectZero)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
}