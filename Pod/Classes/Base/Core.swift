public class Core: UIBaseObject {
    public private(set) var sources:[NSURL]
    public private(set) var containers:[Container]!
    private var loader: Loader
    
    public convenience init(sources: [NSURL]) {
        self.init(sources: sources, loader: Loader())
    }
    
    public required init(sources: [NSURL], loader: Loader) {
        self.sources = sources
        self.loader = loader
        super.init(frame: CGRectZero)
        self.createContainers()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
    
    private func createContainers() {
        let factory = ContainerFactory(sources: sources, loader: loader)
        containers = factory.createContainers()
    }
}