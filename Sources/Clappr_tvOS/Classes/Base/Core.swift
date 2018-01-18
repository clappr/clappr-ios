open class Core: UIBaseObject, UIGestureRecognizerDelegate {
    open var options: Options
    fileprivate(set) open var containers: [Container] = []
    fileprivate(set) open var mediaControl: MediaControl?
    fileprivate(set) open var plugins: [UICorePlugin] = []

    open var parentController: UIViewController?
    open var parentView: UIView?

    fileprivate lazy var fullscreenController = FullscreenController(nibName: nil, bundle: nil)

    open weak var activeContainer: Container?

    open var activePlayback: Playback? {
        return activeContainer?.playback
    }

    open var isFullscreen: Bool {
        return fullscreenController.presentingViewController != nil
    }

    public required init?(coder _: NSCoder) {
        fatalError("Should be using init(sources:[NSURL]) instead")
    }

    public required init(loader: Loader = Loader(), options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")

        self.options = options

        super.init(frame: CGRect.zero)

        backgroundColor = UIColor.black

        mediaControl = loader.mediaControl.create()
        addTapRecognizer()

        bindEventListeners()
        loadPlugins(loader)

        containers.append(Container(loader: loader, options: options))

        if let container = containers.first {
            setActiveContainer(container)
            mediaControl?.setup(container)
        }
    }

    fileprivate func setActiveContainer(_ container: Container) {
        if activeContainer != container {
            activeContainer?.stopListening()

            trigger(InternalEvent.willChangeActiveContainer.rawValue)

            activeContainer = container

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

    fileprivate func loadPlugins(_ loader: Loader) {
        for plugin in loader.corePlugins {
            if let corePlugin = plugin.init(context: self) as? UICorePlugin {
                addPlugin(corePlugin)
            }
        }
    }

    fileprivate func addTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: mediaControl, action: #selector(MediaControl.toggleVisibility))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }

    fileprivate func bindEventListeners() {
        guard let mediaControl = self.mediaControl else {
            return
        }

        listenTo(mediaControl, eventName: Event.requestFullscreen.rawValue) { [weak self] (userInfo: EventUserInfo) in self?.enterFullscreen(userInfo) }
        listenTo(mediaControl, eventName: Event.exitFullscreen.rawValue) { [weak self] (userInfo: EventUserInfo) in self?.exitFullscreen(userInfo) }
    }

    fileprivate func enterFullscreen(_: EventUserInfo) {
        trigger(InternalEvent.willEnterFullscreen.rawValue)
        mediaControl?.fullscreen = true
        fullscreenController.view.backgroundColor = UIColor.black
        fullscreenController.modalPresentationStyle = .overFullScreen
        parentController?.present(fullscreenController, animated: false, completion: nil)
        fullscreenController.view.addSubviewMatchingConstraints(self)
        trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    fileprivate func exitFullscreen(_: EventUserInfo) {
        trigger(InternalEvent.willExitFullscreen.rawValue)
        renderInContainerView()
        fullscreenController.dismiss(animated: false, completion: nil)
        trigger(InternalEvent.didExitFullscreen.rawValue)
    }

    fileprivate func renderInContainerView() {
        mediaControl?.fullscreen = false
        parentView?.addSubviewMatchingConstraints(self)
    }

    open override func render() {
        addToContainer()

        containers.forEach(renderContainer)
        plugins.forEach(installPlugin)

        if let mediaControl = self.mediaControl {
            addSubviewMatchingConstraints(mediaControl)
            mediaControl.render()
        }
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

    fileprivate func renderContainer(_ container: Container) {
        addSubviewMatchingConstraints(container)
        container.render()
    }

    open func addPlugin(_ plugin: UICorePlugin) {
        plugins.append(plugin)
    }

    open func hasPlugin(_ pluginClass: AnyClass) -> Bool {
        return plugins.filter({ $0.isKind(of: pluginClass) }).count > 0
    }

    open func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view!.isKind(of: Container.self) || touch.view == mediaControl
    }

    open func setFullscreen(_ fullscreen: Bool) {
        let isFullscreen = fullscreenController.presentingViewController != nil
        guard fullscreen != isFullscreen else { return }
        fullscreen ? enterFullscreen(nil) : exitFullscreen([:])
    }

    open func destroy() {
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

        Logger.logDebug("destroying mediaControl", scope: "Core")
        mediaControl?.destroy()

        trigger(InternalEvent.didDestroy.rawValue)

        Logger.logDebug("destroyed", scope: "Core")
    }
}
