public class Core: UIBaseObject, UIGestureRecognizerDelegate {
    public private(set) var options: Options
    public private(set) var container: Container!
    public private(set) var mediaControl: MediaControl!
    public private(set) var plugins: [UICorePlugin] = []
    
    public var parentController: UIViewController?
    public var parentView: UIView?
    private var loader: Loader
    private lazy var fullscreenController = FullscreenController(nibName: nil, bundle: nil)

    public var activeContainer: Container? {
        return container
    }

    public var activePlayback: Playback? {
        return activeContainer?.playback
    }

    public var isFullscreen: Bool {
        return self.fullscreenController.presentingViewController != nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
    
    public required init(loader: Loader = Loader(), options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(self.dynamicType)")
        self.loader = loader
        self.options = options
        super.init(frame: CGRectZero)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.blackColor()
        createContainers()
        createMediaControl()
        bindEventListeners()
    }
    
    private func createContainers() {
        container = Container(loader: loader, options: options)
    }
    
    private func createMediaControl() {
        mediaControl = loader.mediaControl.create()
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
    
    private func bindEventListeners() {
        listenTo(mediaControl, eventName: MediaControlEvent.FullscreenEnter.rawValue, callback: enterFullscreen)
        listenTo(mediaControl, eventName: MediaControlEvent.FullscreenExit.rawValue, callback: exitFullscreen)
    }
    
    private func enterFullscreen(_: EventUserInfo) {
        mediaControl.fullscreen = true
        fullscreenController.view.backgroundColor = UIColor.blackColor()
        fullscreenController.modalPresentationStyle = .OverFullScreen
        parentController?.presentViewController(fullscreenController, animated: false, completion: nil)
        fullscreenController.view.addSubviewMatchingConstraints(self)
        trigger(CoreEvent.EnterFullscreen.rawValue)
    }
    
    private func exitFullscreen(_: EventUserInfo) {
        renderInContainerView()
        fullscreenController.dismissViewControllerAnimated(false, completion: nil)
        trigger(CoreEvent.ExitFullscreen.rawValue)
    }
    
    private func renderInContainerView() {
        mediaControl.fullscreen = false
        parentView?.addSubviewMatchingConstraints(self)
    }
    
    public override func render() {
        addToContainer()
        
        plugins.forEach(installPlugin)
        
        addSubviewMatchingConstraints(container)
        addSubviewMatchingConstraints(mediaControl)
        
        mediaControl.render()
        container.render()
    }
    
    private func addToContainer() {
        if let fullscreen = options[kFullscreen] as? Bool {
            fullscreen ? enterFullscreen([:]) : renderInContainerView()
        } else {
            renderInContainerView()
        }
    }
    
    private func installPlugin(plugin: UICorePlugin) {
        addSubview(plugin)
        plugin.render()
    }
    
    public func addPlugin(plugin: UICorePlugin) {
        plugins.append(plugin)
    }
    
    public func hasPlugin(pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKindOfClass(pluginClass)}).count > 0
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view!.isKindOfClass(Container) || touch.view == mediaControl
    }
    
    public func setFullscreen(fullscreen: Bool) {
        let isFullscreen = self.fullscreenController.presentingViewController != nil
        guard fullscreen != isFullscreen else {return}
        fullscreen ? enterFullscreen(nil) : exitFullscreen([:])
    }
}
