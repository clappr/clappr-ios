
public class Core: UIBaseObject, UIGestureRecognizerDelegate {
    public private(set) var options: Options
    public private(set) var container: Container?
    public private(set) var mediaControl: MediaControl!
    public private(set) var plugins: [UICorePlugin] = []
    
    public var parentController: UIViewController?
    private var loader: Loader
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
    
    public required init(loader: Loader = Loader(), options: Options = [:]) {
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
        let factory = ContainerFactory(loader: loader, options: options)
        
        if let container = factory.createContainer() {
            self.container = container
            addSubviewMatchingConstraints(container)
        }
    }
    
    private func createMediaControl() {
        mediaControl = loader.mediaControl.initFromNib()
        addSubviewMatchingConstraints(mediaControl)
        addTapRecognizer()
        
        if let container = container {
            mediaControl.setup(container)
        }
    }
    
    private func addTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: mediaControl, action: #selector(MediaControl.toggleVisibility))
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