open class Core: UIBaseObject, UIGestureRecognizerDelegate {
    @objc open var options: Options {
        didSet {
            containers.forEach { $0.options = options }
            trigger(Event.didUpdateOptions)
            loadSourceIfNeeded()
        }
    }
    @objc fileprivate(set) open var containers: [Container] = []
    @objc fileprivate(set) open var plugins: [UICorePlugin] = []

    @objc open weak var parentController: UIViewController?
    @objc open var parentView: UIView?

    #if os(iOS)
    @objc private (set) var fullscreenController: FullscreenController? = FullscreenController(nibName: nil, bundle: nil)

    lazy var fullscreenHandler: FullscreenStateHandler? = {
        return self.optionsUnboxer.fullscreenControledByApp ? FullscreenByApp(core: self) : FullscreenByPlayer(core: self) as FullscreenStateHandler
    }()
    #endif

    lazy var optionsUnboxer: OptionsUnboxer = OptionsUnboxer(options: self.options)

    @objc open weak var activeContainer: Container? {

        willSet {
            activeContainer?.stopListening()
            trigger(InternalEvent.willChangeActiveContainer.rawValue)
        }

        didSet {
            activeContainer?.on(
            InternalEvent.willChangePlayback.rawValue) { [weak self] (info: EventUserInfo) in
                self?.trigger(InternalEvent.willChangeActivePlayback.rawValue, userInfo: info)
            }

            activeContainer?.on(
            InternalEvent.didChangePlayback.rawValue) { [weak self] (info: EventUserInfo) in
                self?.trigger(InternalEvent.didChangeActivePlayback.rawValue, userInfo: info)
            }
            trigger(InternalEvent.didChangeActiveContainer.rawValue)
        }
    }

    @objc open var activePlayback: Playback? {
        return activeContainer?.playback
    }

    @objc open var isFullscreen: Bool = false

    public required init?(coder _: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }

    public required init(options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")

        self.options = options

        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.black

        addTapRecognizer()
        bindEventListeners()
        Loader.shared.loadPlugins(in: self)

        containers.append(Container(options: options))

        if let container = containers.first {
            setActive(container: container)
        }
    }

    fileprivate func setActive(container: Container) {
        if activeContainer != container {
            activeContainer = container
        }
    }

    fileprivate func addTapRecognizer() {
        #if os(iOS)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedView))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
        #endif
    }

    fileprivate func bindEventListeners() {
        #if os(iOS)
        listenTo(self, eventName: InternalEvent.userRequestEnterInFullscreen.rawValue) { [weak self] _ in self?.fullscreenHandler?.enterInFullscreen() }
        listenTo(self, eventName: InternalEvent.userRequestExitFullscreen.rawValue) { [weak self] _ in self?.fullscreenHandler?.exitFullscreen() }
        #endif
    }

    fileprivate func renderInContainerView() {
        isFullscreen = false
        parentView?.addSubviewMatchingConstraints(self)
    }

    open override func render() {
        containers.forEach(renderContainer)
        #if os(iOS)
        renderCoreAndMediaControlPlugins()
        #elseif os(tvOS)
        renderPlugins()
        #endif

        addToContainer()
    }
    
    #if os(tvOS)
    private func renderPlugins() {
        plugins.forEach { plugin in
            addSubview(plugin)
            plugin.render()
        }
    }
    #endif
    
    #if os(iOS)
    private func renderCoreAndMediaControlPlugins() {
        plugins.forEach { plugin in
            if isNotMediaControlPlugin(plugin) {
                addSubview(plugin)
                plugin.render()
            }

            
            if plugin is MediaControl, let mediaControl = plugin as? MediaControl {
                mediaControl.renderPlugins(plugins)
            }
        }
    }

    private func isNotMediaControlPlugin(_ plugin: UICorePlugin) -> Bool {
        return !(plugin is MediaControlPlugin)
    }
    #endif

    fileprivate func addToContainer() {
        #if os(iOS)
        if optionsUnboxer.fullscreen && !optionsUnboxer.fullscreenControledByApp {
            fullscreenHandler?.enterInFullscreen()
        } else {
            renderInContainerView()
        }
        #else
        renderInContainerView()
        #endif
    }

    fileprivate func renderContainer(_ container: Container) {
        addSubviewMatchingConstraints(container)
        container.render()
    }

    fileprivate func loadSourceIfNeeded() {
        if let source = options[kSourceUrl] as? String {
            activeContainer?.load(source, mimeType: options[kMimeType] as? String)
        }
    }

    @objc open func addPlugin(_ plugin: UICorePlugin) {
        plugins.append(plugin)
    }

    @objc open func hasPlugin(_ pluginClass: AnyClass) -> Bool {
        return plugins.filter({ $0.isKind(of: pluginClass) }).count > 0
    }

    open func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view!.isKind(of: Container.self)
    }

    @objc open func setFullscreen(_ fullscreen: Bool) {
        #if os(iOS)
        fullscreenHandler?.set(fullscreen: fullscreen)
        #endif
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Core")

        trigger(InternalEvent.willDestroy.rawValue)

        Logger.logDebug("destroying listeners", scope: "Core")
        stopListening()

        Logger.logDebug("destroying containers", scope: "Core")
        containers.forEach { container in container.destroy() }
        containers.removeAll()

        Logger.logDebug("destroying plugins", scope: "Core")
        plugins.forEach { plugin in plugin.destroy() }
        plugins.removeAll()

        trigger(InternalEvent.didDestroy.rawValue)

        Logger.logDebug("destroyed", scope: "Core")
        #if os(iOS)
        fullscreenHandler?.destroy()
        fullscreenHandler = nil
        fullscreenController = nil
        #endif
        removeFromSuperview()
    }

    @objc func didTappedView() {
        trigger(Event.willShowMediaControl.rawValue)
    }
}
