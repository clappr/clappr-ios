import Foundation

open class MediaControl: UICorePlugin, UIGestureRecognizerDelegate {

    override open var view: UIView {
        didSet {
            addSubview(view)
            view.addSubview(container)

            view.bindFrameToSuperviewBounds()
            container.bindFrameToSuperviewBounds()

            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
            self.gesture = gesture
        }
    }

    public var gesture: UITapGestureRecognizer?

    var container: MediaControlView = .fromNib()

    var options: Options? {
        return core?.options
    }

    private var activeContainer: Container? {
        return core?.activeContainer
    }

    private var activePlayback: Playback? {
        return core?.activePlayback
    }

    public var plugins: [MediaControlPlugin] = []

    override open var pluginName: String {
        return "MediaControl"
    }

    public var hideControlsTimer: Timer?
    public var animationDuration = 0.3
    public var secondsToHideControlFast: TimeInterval = 0.4
    public var secondsToHideControlSlow: TimeInterval = 4

    private var showControls = true

    private var alwaysVisible = false

    required public init(context: UIBaseObject) {
        super.init(context: context)
        alwaysVisible = (core?.options[kMediaControlAlwaysVisible] as? Bool) ?? false
        bindEvents()
    }

    required public init() {
        super.init()
    }

    required public init?(coder argument: NSCoder) {
        super.init(coder: argument)
    }

    private func bindEvents() {
        stopListening()

        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    open func bindCoreEvents() {
        if let core = self.core {

            listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] _ in
                self?.bindEvents()
            }

            listenTo(core, eventName: InternalEvent.didEnterFullscreen.rawValue) { [weak self] _ in
                if self?.hideControlsTimer?.isValid ?? false {
                    self?.disappearAfterSomeTime()
                }
            }

            listenTo(core, eventName: InternalEvent.didExitFullscreen.rawValue) { [weak self] _ in
                if self?.hideControlsTimer?.isValid ?? false {
                    self?.disappearAfterSomeTime()
                }
            }

            listenTo(core, eventName: Event.willShowMediaControl.rawValue) { [weak self] _ in
                self?.toggleVisibility()
            }
        }
    }

    private func bindContainerEvents() {
        if let container = activeContainer {
            listenTo(container,
                     eventName: InternalEvent.didChangePlayback.rawValue) { [weak self] _ in self?.bindEvents() }
            listenTo(container,
                     eventName: Event.enableMediaControl.rawValue) { [weak self] _ in self?.show() }
            listenTo(container,
                     eventName: Event.disableMediaControl.rawValue) { [weak self] _ in self?.hide() }
        }
    }

    private func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in
                self?.showControls = true
                self?.show { [weak self] in
                    self?.disappearAfterSomeTime()
                }
            }

            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in
                self?.hide()
            }

            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in
                self?.show { [weak self] in
                    self?.disappearAfterSomeTime()
                }
            }

            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in
                self?.keepVisible()
            }

            listenTo(playback, eventName: Event.error.rawValue) { [weak self] _ in
                self?.showControls = false
            }
        }
    }

    func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        let duration = animated ? animationDuration : 0

        if self.alpha == 0 {
            self.isHidden = false
        }

        UIView.animate(
            withDuration: duration,
            animations: {
                self.alpha = 1
        },
            completion: { _ in
                self.isHidden = false
                completion?()
        }
        )
    }

    func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
        if !alwaysVisible {
            let duration = animated ? animationDuration : 0

            UIView.animate(
                withDuration: duration,
                animations: {
                    self.alpha = 0
            },
                completion: { _ in
                    self.isHidden = true
                    completion?()
            }
            )
        }
    }

    public func disappearAfterSomeTime(_ duration: TimeInterval? = nil) {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: duration ?? secondsToHideControlFast,
                                                 target: self, selector: #selector(MediaControl.hideAndStopTimer), userInfo: nil, repeats: false)
    }

    public func keepVisible() {
        hideControlsTimer?.invalidate()
    }

    @objc func hideAndStopTimer() {
        hideControlsTimer?.invalidate()
        hide(animated: true)
    }

    @objc func tapped() {
        hideAndStopTimer()
    }

    override open func render() {
        self.isHidden = true
        view = UIView()
        view.backgroundColor = UIColor.clapprBlack60Color()

        loadPlugins()
        loadDefaultPlugins()
        renderPlugins()
        showIfAlwaysVisible()

        self.bindFrameToSuperviewBounds()
    }

    private func loadPlugins() {
        guard let mediaControlPlugins = options?[kMediaControlPlugins] as? [MediaControlPlugin.Type] else {
            return
        }

        mediaControlPlugins.forEach { plugin in
            plugins.append(plugin.init(context: core!))
        }
    }

    private func loadDefaultPlugins() {
        if let disableDefaultPlugins = options?[kDisableDefaultPlugins] as? Bool, disableDefaultPlugins {
            return
        }

        defaultPlugins.forEach { defaultPlugin in
            addPlugin(defaultPlugin)
        }
    }

    private func addPlugin(_ plugin: MediaControlPlugin.Type) {
        if !plugins.contains(where: { $0.pluginName == plugin.name}) {
            plugins.append(plugin.init(context: core!))
        }
    }
    
    private func renderPlugins() {
        plugins.forEach { plugin in
            container.addSubview(plugin.view, panel: plugin.panel, position: plugin.position)

            plugin.render()
        }
    }

    private func showIfAlwaysVisible() {
        if alwaysVisible {
            show()
        }
    }

    fileprivate func toggleVisibility() {
        if showControls {
            show(animated: true) { [weak self] in
                self?.disappearAfterSomeTime(self?.secondsToHideControlSlow)
            }
        }
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
