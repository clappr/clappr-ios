open class Core: UIObject, UIGestureRecognizerDelegate {
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
            trigger(Event.willChangeActiveContainer.rawValue)
        }

        didSet {
            activeContainer?.on(
            Event.willChangePlayback.rawValue) { [weak self] (info: EventUserInfo) in
                self?.trigger(Event.willChangeActivePlayback.rawValue, userInfo: info)
            }

            activeContainer?.on(
            Event.didChangePlayback.rawValue) { [weak self] (info: EventUserInfo) in
                self?.trigger(Event.didChangeActivePlayback.rawValue, userInfo: info)
            }
            trigger(Event.didChangeActiveContainer.rawValue)
        }
    }

    @objc open var activePlayback: Playback? {
        return activeContainer?.playback
    }

    @objc open var isFullscreen: Bool = false

    public required init(options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")

        self.options = options

        super.init()

        view.backgroundColor = UIColor.black

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
        view.addGestureRecognizer(tapRecognizer)
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
        parentView?.addSubviewMatchingConstraints(view)
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
            view.addSubview(plugin.view)
            plugin.render()
        }
    }
    #endif

    #if os(iOS)
    private func renderCoreAndMediaControlPlugins() {
        plugins.forEach { plugin in
            if isNotMediaControlPlugin(plugin) {
                view.addSubview(plugin.view)
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
        view.addSubviewMatchingConstraints(container.view)
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
        return touch.view!.accessibilityIdentifier == "Container"
    }

    @objc open func setFullscreen(_ fullscreen: Bool) {
        #if os(iOS)
        fullscreenHandler?.set(fullscreen: fullscreen)
        #endif
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Core")

        trigger(Event.willDestroy.rawValue)

        Logger.logDebug("destroying listeners", scope: "Core")
        stopListening()

        Logger.logDebug("destroying containers", scope: "Core")
        containers.forEach { container in container.destroy() }
        containers.removeAll()

        Logger.logDebug("destroying plugins", scope: "Core")
        plugins.forEach { plugin in plugin.destroy() }
        plugins.removeAll()

        trigger(Event.didDestroy.rawValue)

        Logger.logDebug("destroyed", scope: "Core")
        #if os(iOS)
        fullscreenHandler?.destroy()
        fullscreenHandler = nil
        fullscreenController = nil
        #endif
        view.removeFromSuperview()
    }

    @objc func didTappedView() {
        trigger(InternalEvent.didTappedCore.rawValue)
    }
}
