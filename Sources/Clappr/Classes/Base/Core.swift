public typealias SharedData = [String: Any]

open class Core: UIObject, UIGestureRecognizerDelegate {

    @objc public let environment = Environment()
    @objc open var sharedData = SharedData()

    @objc open var options: Options {
        didSet {
            containers.forEach { $0.options = options }
            trigger(Event.didUpdateOptions)
        }
    }
    @objc fileprivate(set) open var containers: [Container] = []
    fileprivate(set) open var plugins: [Plugin] = []

    @objc open weak var parentController: UIViewController?
    @objc open var parentView: UIView?
    @objc open var overlayView = PassthroughView()

    #if os(iOS)
    @objc private (set) var fullscreenController: FullscreenController? = FullscreenController(nibName: nil, bundle: nil)

    lazy var fullscreenHandler: FullscreenStateHandler? = {
        return self.optionsUnboxer.fullscreenControledByApp ? FullscreenByApp(core: self) : FullscreenByPlayer(core: self) as FullscreenStateHandler
    }()
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

    public required init(options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")

        self.options = options
        super.init()

        view.backgroundColor = .black

        addTapGestures()
        bindEventListeners()
        
        Loader.shared.corePlugins.forEach { addPlugin($0.init(context: self)) }
    }
    
    func load() {
        if let source = options[kSourceUrl] as? String {
            trigger(.willLoadSource)
            activeContainer?.load(source, mimeType: options[kMimeType] as? String)
        }
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

    fileprivate func bindEventListeners() {
        #if os(iOS)
        listenTo(self, eventName: InternalEvent.userRequestEnterInFullscreen.rawValue) { [weak self] _ in self?.fullscreenHandler?.enterInFullscreen() }
        listenTo(self, eventName: InternalEvent.userRequestExitFullscreen.rawValue) { [weak self] _ in self?.fullscreenHandler?.exitFullscreen() }
        orientationObserver = OrientationObserver(core: self)
        #endif
    }

    fileprivate func renderInContainerView() {
        isFullscreen = false
        parentView?.addSubviewMatchingConstraints(view)
    }

    open func attach(to parentView: UIView, controller: UIViewController) {
        self.parentController = controller
        self.parentView = parentView
        trigger(.didAttachView)
    }

    open override func render() {
        parentView?.addSubviewMatchingConstraints(overlayView)
        containers.forEach(renderContainer)
        addToContainer()
        parentView?.bringSubviewToFront(overlayView)
    }

    #if os(tvOS)
    private func renderPlugins() {
        plugins.forEach(render)
    }
    #endif

    #if os(iOS)

    private func renderCorePlugins() {
        plugins.filter(isNotMediaControlElement).forEach(render)
    }

    private var mediaControl: MediaControl? {
        return plugins.first { $0 is MediaControl } as? MediaControl
    }

    private var mediaControlElements: [MediaControl.Element] {
        return plugins.compactMap { $0 as? MediaControl.Element }
    }

    private func renderMediaControlElements() {
        mediaControl?.renderElements(mediaControlElements)
    }

    private func isNotMediaControlElement(_ plugin: Plugin) -> Bool {
        return !(plugin is MediaControl.Element)
    }

    #endif

    private var overlayPlugins: [OverlayPlugin] {
        return plugins.compactMap { $0 as? OverlayPlugin }
    }

    private func renderOverlayPlugins() {
        overlayPlugins.forEach(render)
    }

    private func viewThatRenders(_ plugin: Plugin) -> UIView {
        return plugin is OverlayPlugin ? overlayView : view
    }

    private func shouldFitParentView(_ plugin: Plugin) -> Bool {
        return (plugin as? OverlayPlugin)?.isModal == true
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
        do {
            try ObjC.catchException {
                plugin.render()
            }
        } catch {
            plugin.logRenderCrash(for: error)
        }
    }

    private var shouldEnterInFullScreen: Bool {
        return optionsUnboxer.fullscreen && !optionsUnboxer.fullscreenControledByApp
    }

    fileprivate func addToContainer() {
        #if os(iOS)
        if shouldEnterInFullScreen {
            renderCorePlugins()
            renderMediaControlElements()
            fullscreenHandler?.enterInFullscreen()
        } else {
            renderInContainerView()
            renderCorePlugins()
            renderMediaControlElements()
        }
        renderOverlayPlugins()
        #else
        renderInContainerView()
        renderPlugins()
        #endif
    }

    fileprivate func renderContainer(_ container: Container) {
        view.addSubviewMatchingConstraints(container.view)
        container.render()
    }

    open func addPlugin(_ plugin: Plugin) {
        plugins.append(plugin)
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
        plugins.forEach(safeDestroy)
        plugins.removeAll()

        Logger.logDebug("destroyed", scope: "Core")
        #if os(iOS)
        fullscreenHandler?.destroy()
        fullscreenHandler = nil
        fullscreenController = nil
        orientationObserver = nil
        #endif
        view.removeFromSuperview()

        trigger(.didDestroy)
    }

    private func safeDestroy(_ plugin: Plugin) {
        do {
            try ObjC.catchException {
                plugin.destroy()
            }
        } catch {
            plugin.logDestroyCrash(for: error)
        }
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
}
