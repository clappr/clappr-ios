public class Core: UIBaseObject {
    public private(set) var sources: [NSURL]
    public private(set) var containers: [Container]!
    public private(set) var mediaControl: MediaControl!
    public private(set) var plugins: [UICorePlugin] = []
    private var loader: Loader
    
    public convenience init(sources: [NSURL]) {
        self.init(sources: sources, loader: Loader())
    }
    
    public required init(sources: [NSURL], loader: Loader) {
        self.sources = sources
        self.loader = loader
        super.init(frame: CGRectZero)
        self.load()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
    
    private func load() {
        createContainers()
        createMediaControl()
    }
    
    private func createContainers() {
        let factory = ContainerFactory(sources: sources, loader: loader)
        containers = factory.createContainers()
    }
    
    private func createMediaControl() {
        if let topContainer = containers.first {
            mediaControl = MediaControl.initWithContainer(topContainer)
        }
    }
    
    public func addPlugin(plugin: UICorePlugin) {
        plugin.core = self
        plugins.append(plugin)
        addSubview(plugin)
    }
}