public class Core: UIBaseObject, UIGestureRecognizerDelegate {
    public private(set) var options: Options
    public private(set) var sources: [NSURL]
    public private(set) var containers: [Container]!
    public private(set) var mediaControl: MediaControl!
    public private(set) var plugins: [UICorePlugin] = []
    
    public var parentController: UIViewController?
    private var loader: Loader
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
    
    public required init(sources: [NSURL], loader: Loader = Loader(), options: Options = [:]) {
        self.sources = sources
        self.loader = loader
        self.options = options
        super.init(frame: CGRectZero)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.blackColor()
        createContainers()
        createMediaControl()
    }
    
    private func createContainers() {
        let factory = ContainerFactory(sources: sources, loader: loader, options: options)
        containers = factory.createContainers()
        
        for container in containers {
            addSubviewMatchingConstraints(container)
        }
    }
    
    private func createMediaControl() {
        mediaControl = MediaControl.initFromNib()
        addSubviewMatchingConstraints(mediaControl)
        addTapRecognizer()
        
        if let topContainer = containers.first {
            mediaControl.setup(topContainer)
        }
    }
    
    private func addTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: mediaControl, action: "toggleVisibility")
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }
    
    public func addPlugin(plugin: UICorePlugin) {
        plugin.core = self
        installPlugin(plugin)
        plugin.wasInstalled()
    }
    
    private func installPlugin(plugin: UICorePlugin) {
        plugins.append(plugin)
        addSubview(plugin)
        bringSubviewToFront(mediaControl)
    }
    
    public func hasPlugin(pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKindOfClass(pluginClass)}).count > 0
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view!.isKindOfClass(Container) || touch.view == mediaControl
    }
}