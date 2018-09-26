import Foundation

class ClapprMediaControl: UICorePlugin {

    override var view: UIView! {
        didSet {
            addSubview(view)
            view.addSubview(container)

            view.bindFrameToSuperviewBounds()
            container.bindFrameToSuperviewBounds()
        }
    }

    private var gesture: UITapGestureRecognizer?

    var container: ClapprMediaControlView = .fromNib()

    var options: Options? {
        return core?.options
    }

    private var activeContainer: Container? {
        return core?.activeContainer
    }

    private var activePlayback: Playback? {
        return core?.activePlayback
    }

    internal(set) var plugins: [MediaControlPlugin] = []

    override var pluginName: String {
        return "ClapprMediaControl"
    }

    var hideControlsTimer: Timer?
    var animationDuration = 0.3
    var secondsToHideControlFast: TimeInterval = 0.4
    var secondsToHideControlSlow: TimeInterval = 4

    private var showControls = true

    private var alwaysVisible = false

    required init(context: UIBaseObject) {
        super.init(context: context)
        alwaysVisible = (core?.options[kMediaControlAlwaysVisible] as? Bool) ?? false
        bindEvents()
    }

    required init() {
        super.init()
    }

    required init?(coder argument: NSCoder) {
        super.init(coder: argument)
    }

    private func bindEvents() {
        stopListening()

        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    func bindCoreEvents() {
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

    private func disappearAfterSomeTime(_ duration: TimeInterval? = nil) {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: duration ?? secondsToHideControlFast,
                                                 target: self, selector: #selector(ClapprMediaControl.hideAndStopTimer), userInfo: nil, repeats: false)
    }

    private func keepVisible() {
        hideControlsTimer?.invalidate()
    }

    @objc func hideAndStopTimer() {
        hideControlsTimer?.invalidate()
        hide(animated: true)
    }

    @objc func tapped(sender: UITapGestureRecognizer) {
        hideAndStopTimer()
    }

    override func render() {
        self.isHidden = true
        view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        
        loadPlugins()
        renderPlugins()
        showIfAlwaysVisible()

        self.bindFrameToSuperviewBounds()
    }

    private func loadPlugins() {
        guard let mediaControlPlugins = options?["mediaControlPlugins"] as? [MediaControlPlugin.Type] else {
            return
        }

        mediaControlPlugins.forEach { plugin in
            plugins.append(plugin.init(context: core!))
        }
    }

    private func renderPlugins() {
        plugins.forEach { plugin in
            guard let view = plugin.view else { return }
            container.addSubview(view, panel: plugin.panel, position: plugin.position)

            plugin.render()
        }
    }

    private func showIfAlwaysVisible() {
        if alwaysVisible {
            show()
        }
    }

}
