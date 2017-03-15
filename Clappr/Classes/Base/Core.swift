open class Core: UIBaseObject, UIGestureRecognizerDelegate {
    open fileprivate(set) var options: Options
    open fileprivate(set) var container: Container!
    open fileprivate(set) var mediaControl: MediaControl!
    open fileprivate(set) var plugins: [UICorePlugin] = []
    
    open var parentController: UIViewController?
    open var parentView: UIView?
    fileprivate var loader: Loader
    fileprivate lazy var fullscreenController = FullscreenController(nibName: nil, bundle: nil)

    open var activeContainer: Container? {
        return container
    }

    open var activePlayback: Playback? {
        return activeContainer?.playback
    }

    open var isFullscreen: Bool {
        return self.fullscreenController.presentingViewController != nil
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }
    
    public required init(loader: Loader = Loader(), options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.loader = loader
        self.options = options
        super.init(frame: CGRect.zero)
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = UIColor.black
        createContainers()
        createMediaControl()
        bindEventListeners()
    }
    
    fileprivate func createContainers() {
        let factory = ContainerFactory(loader: loader, options: options)
        container = factory.createContainer()
    }
    
    fileprivate func createMediaControl() {
        mediaControl = loader.mediaControl.create()
        addTapRecognizer()
        
        if let container = container {
            mediaControl.setup(container)
        }
    }
    
    fileprivate func addTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: mediaControl, action: #selector(MediaControl.toggleVisibility))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }
    
    fileprivate func bindEventListeners() {
        listenTo(mediaControl, eventName: MediaControlEvent.FullscreenEnter.rawValue, callback: enterFullscreen)
        listenTo(mediaControl, eventName: MediaControlEvent.FullscreenExit.rawValue, callback: exitFullscreen)
    }
    
    fileprivate func enterFullscreen(_: EventUserInfo) {
        mediaControl.fullscreen = true
        fullscreenController.view.backgroundColor = UIColor.black
        fullscreenController.modalPresentationStyle = .overFullScreen
        parentController?.present(fullscreenController, animated: false, completion: nil)
        fullscreenController.view.addSubviewMatchingConstraints(self)
        trigger(CoreEvent.EnterFullscreen.rawValue)
    }
    
    fileprivate func exitFullscreen(_: EventUserInfo) {
        renderInContainerView()
        fullscreenController.dismiss(animated: false, completion: nil)
        trigger(CoreEvent.ExitFullscreen.rawValue)
    }
    
    fileprivate func renderInContainerView() {
        mediaControl.fullscreen = false
        parentView?.addSubviewMatchingConstraints(self)
    }
    
    open override func render() {
        addToContainer()
        
        plugins.forEach(installPlugin)
        
        addSubviewMatchingConstraints(container)
        addSubviewMatchingConstraints(mediaControl)
        
        mediaControl.render()
        container.render()
    }
    
    fileprivate func addToContainer() {
        if let fullscreen = options[kFullscreen] as? Bool {
            fullscreen ? enterFullscreen([:]) : renderInContainerView()
        } else {
            renderInContainerView()
        }
    }
    
    fileprivate func installPlugin(_ plugin: UICorePlugin) {
        addSubview(plugin)
        plugin.render()
    }
    
    open func addPlugin(_ plugin: UICorePlugin) {
        plugins.append(plugin)
    }
    
    open func hasPlugin(_ pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKind(of: pluginClass)}).count > 0
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view!.isKind(of: Container.self) || touch.view == mediaControl
    }
    
    open func setFullscreen(_ fullscreen: Bool) {
        let isFullscreen = self.fullscreenController.presentingViewController != nil
        guard fullscreen != isFullscreen else {return}
        fullscreen ? enterFullscreen(nil) : exitFullscreen([:])
    }
}
