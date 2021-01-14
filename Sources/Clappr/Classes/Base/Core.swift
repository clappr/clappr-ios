public typealias SharedData = [String: Any]

open class Core: UIObject, UIGestureRecognizerDelegate {
    
    private var layerComposer: LayerComposer
    @objc public let environment = Environment()
    @objc open var sharedData = SharedData()

    @objc open var options: Options {
        didSet {
            containers.forEach { $0.options = options }
            updateChromelessMode()
            trigger(Event.didUpdateOptions)
        }
    }
    @objc private(set) open var containers: [Container] = []
    private(set) open var plugins: [Plugin] = []

    @objc open weak var parentController: UIViewController?
    @objc open var parentView: UIView?
    @objc open var overlayView = PassthroughView()

    #if os(iOS)
    lazy var fullscreenHandler: FullscreenStateHandler? = FullscreenByApp(core: self)
    private var orientationObserver: OrientationObserver?
    #endif

    lazy var optionsUnboxer: OptionsUnboxer = OptionsUnboxer(options: self.options)

    @objc open weak var activeContainer: Container? {

        willSet {
            activeContainer?.stopListening()
            trigger(.willChangeActiveContainer)
        }

        didSet {
            activeContainer?.on(Event.willChangePlayback.rawValue) { [weak self] info in
                self?.trigger(.willChangeActivePlayback, userInfo: info)
            }

            activeContainer?.on(Event.didChangePlayback.rawValue) { [weak self] info in
                self?.trigger(.didChangeActivePlayback, userInfo: info)
            }

            trigger(.didChangeActiveContainer)
        }
    }

    @objc open var activePlayback: Playback? {
        return activeContainer?.playback
    }

    @objc open var isFullscreen: Bool = false
    public var chromelessMode: Bool = false {
        didSet {
            updateLayersVisibility()
            updateGestureRecognizersState()
        }
    }
    
    public required init(options: Options = [:], layerComposer: LayerComposer) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")

        self.options = options
        self.layerComposer = layerComposer
        super.init()
        
        updateChromelessMode()
        
        bindEventListeners()
        
        Loader.shared.corePlugins.forEach { addPlugin($0.init(context: self)) }
    }

    func load() {
        guard let source = options[kSourceUrl] as? String else { return }
        trigger(.willLoadSource)
        activeContainer?.load(source, mimeType: options[kMimeType] as? String)
    }
    
    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view!.accessibilityIdentifier == "Container"
    }
    
    public func add(container: Container) {
        containers.append(container)
    }

    public func setActive(container: Container) {
        if activeContainer != container {
            activeContainer = container
        }
    }
    
    private func updateLayersVisibility() {
        #if os(iOS)
        chromelessMode ? layerComposer.hideUI() : layerComposer.showUI()
        #endif
    }
    
    private func updateGestureRecognizersState() {
        #if os(iOS)
        view.gestureRecognizers?.forEach { $0.isEnabled = !chromelessMode }
        #endif
    }
    
    private func updateChromelessMode() {
        if let chromelessMode = options[kChromeless] as? Bool {
            self.chromelessMode = chromelessMode
        }
    }

    private func bindEventListeners() {
        #if os(iOS)
        listenTo(self, eventName: InternalEvent.userRequestEnterInFullscreen.rawValue) { [weak self] _ in self?.fullscreenHandler?.enterInFullscreen() }
        listenTo(self, eventName: InternalEvent.userRequestExitFullscreen.rawValue) { [weak self] _ in self?.onUserRequestExitFullscreen() }
        orientationObserver = OrientationObserver(core: self)
        #endif
    }
    
    private func onUserRequestExitFullscreen() {
        #if os(iOS)
        if optionsUnboxer.fullscreenDisabled {
            trigger(InternalEvent.requestDestroyPlayer.rawValue)
        }
        #endif
    } 
    
    open func attach(to parentView: UIView, controller: UIViewController) {
        guard let containerView = activeContainer?.view else {
            Logger.logError("Active container should not be nil when attaching to parent view", scope: "Core")
            return
        }
        parentView.addSubviewMatchingConstraints(view)
    
        layerComposer.attachContainer(containerView)
        layerComposer.attachOverlay(overlayView)
        layerComposer.compose(inside: view)
        
        self.parentController = controller
        self.parentView = parentView
    
        trigger(.didAttachView)
    }
    
    open override func render() {
        addTapGestures()
        containers.forEach(renderContainer)
        addToContainer()
        updateGestureRecognizersState()
    }

    private func addToContainer() {
        #if os(iOS)
        renderCorePlugins()
        renderMediaControlElements()
        renderOverlayPlugins()
        #else
        renderPlugins()
        #endif
        parentView?.addSubviewMatchingConstraints(view)
    }

    private func renderContainer(_ container: Container) {
        #if os(tvOS)
        view.addSubviewMatchingConstraints(container.view)
        #endif
        container.render()
    }

    #if os(tvOS)
    private func renderPlugins() {
        plugins.forEach(render)
    }
    #endif

    #if os(iOS)
    private func renderCorePlugins() {
        attachMediaControlLayer()
        plugins
            .filter { $0.isNotMediaControlElement }
            .filter { $0.isNotOverlayPlugin }
            .filter { $0.isNotMediaControl }
            .compactMap { $0 as? UICorePlugin }
            .forEach { plugin in
                layerComposer.attachUICorePlugin(plugin)
                plugin.safeRender()
        }
    }
    
    private func attachMediaControlLayer() {
        guard let mediaControl = plugins.first(where: { $0 is MediaControl }) as? MediaControl else {
            return
        }

        layerComposer.attachMediaControl(mediaControl.view)
        mediaControl.safeRender()
    }

    private func renderMediaControlElements() {
        let mediaControl = plugins.first { $0 is MediaControl } as? MediaControl
        let elements = plugins.compactMap { $0 as? MediaControl.Element }
        mediaControl?.render(elements)
    }

    private func renderOverlayPlugins() {
        plugins
            .compactMap { $0 as? OverlayPlugin }
            .forEach(render)
    }
    #endif

    private func viewThatRenders(_ plugin: Plugin) -> UIView {
        return plugin is OverlayPlugin ? overlayView : view
    }

    private func add(_ plugin: UICorePlugin, to view: UIView) {
        if plugin.shouldFitParentView {
            view.addSubviewMatchingConstraints(plugin.view)
        } else {
            view.addSubview(plugin.view)
        }
    }

    private func render(_ plugin: Plugin) {
        guard let plugin = plugin as? UICorePlugin else { return }
        add(plugin, to: viewThatRenders(plugin))
        plugin.safeRender()
    }

    open func addPlugin(_ plugin: Plugin) {
        let containsPluginWithPlaceholder = plugins.contains(where: { $0.hasPlaceholder })

        if !plugin.hasPlaceholder || !containsPluginWithPlaceholder {
            plugins.append(plugin)
        }
    }
    
    @objc open func setFullscreen(_ fullscreen: Bool) {
        #if os(iOS)
        fullscreenHandler?.set(fullscreen: fullscreen)
        #endif
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Core")

        trigger(.willDestroy)

        Logger.logDebug("destroying listeners", scope: "Core")
        stopListening()

        Logger.logDebug("destroying containers", scope: "Core")
        containers.forEach { $0.destroy() }
        containers.removeAll()

        Logger.logDebug("destroying plugins", scope: "Core")
        plugins.forEach { $0.safeDestroy() }
        plugins.removeAll()

        Logger.logDebug("destroyed", scope: "Core")
        #if os(iOS)
        fullscreenHandler?.destroy()
        fullscreenHandler = nil
        orientationObserver = nil
        #endif
        view.removeFromSuperview()

        trigger(.didDestroy)
    }
}

fileprivate extension Plugin {
    func logRenderCrash(for error: Error) {
        Logger.logError("\(pluginName) crashed during render (\(error.localizedDescription))", scope: "Core")
    }

    func logDestroyCrash(for error: Error) {
        Logger.logError("\(pluginName) crashed during destroy (\(error.localizedDescription))", scope: "Core")
    }

    var shouldFitParentView: Bool {
        return (self as? OverlayPlugin)?.isModal == true
    }

    var hasPlaceholder: Bool {
        #if os(iOS)
            guard let drawer = self as? DrawerPlugin else { return false }
            return drawer.placeholder > .zero
        #else
            return false
        #endif
    }

    #if os(iOS)
    var isNotMediaControl: Bool {
        return !(self is MediaControl)
    }

    var isNotMediaControlElement: Bool {
        return !(self is MediaControl.Element)
    }

    var isNotOverlayPlugin: Bool {
        return !(self is OverlayPlugin)
    }
    #endif

    func safeDestroy() {
        do {
            try ObjC.catchException {
                self.destroy()
            }
        } catch {
            logDestroyCrash(for: error)
        }
    }
}

fileprivate extension UICorePlugin {
    func safeRender() {
        do {
            try ObjC.catchException {
                self.render()
            }
        } catch {
            logRenderCrash(for: error)
        }
    }
}
