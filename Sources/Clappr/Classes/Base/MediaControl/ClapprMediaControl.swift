import Foundation

class GloboMediaControl: UICorePlugin {

    internal(set) var view: UIView! {
        didSet {
            addSubview(view)
            view.addSubview(container)

            view.bindFrameToSuperviewBounds()
            container.bindFrameToSuperviewBounds()

            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(sender:)))
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
            self.gesture = gesture
        }
    }

    private var gesture: UITapGestureRecognizer?

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

    internal(set) var plugins: [MediaControlPlugin] = []

    override var pluginName: String {
        return "GloboMediaControl"
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

            listenTo(core, eventName: PlayerInternalEvent.settingsClosed.rawValue) { [weak self] _ in
                self?.disappearAfterSomeTime()
                self?.view.backgroundColor = .steveBlack60Color()
                if let gesture = self?.gesture {
                    self?.view.addGestureRecognizer(gesture)
                }
            }

            listenTo(core, eventName: PlayerInternalEvent.settingsOpened.rawValue) { [weak self] _ in
                self?.keepVisible()
                self?.view.backgroundColor = .clear
                if let gesture = self?.gesture {
                    self?.view.removeGestureRecognizer(gesture)
                }
            }

            listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] _ in
                self?.bindEvents()
            }

            listenTo(core, eventName: PlayerInternalEvent.showMediaControl.rawValue) { [weak self] _ in
                if self?.showControls ?? true {
                    self?.show(animated: true) { [weak self] in
                        self?.disappearAfterSomeTime(self?.secondsToHideControlSlow)
                    }
                }
            }

            listenTo(core, eventName: PlayerInternalEvent.willBeginScrubbing.rawValue) { [weak self] _ in
                self?.keepVisible()
            }

            listenTo(core, eventName: PlayerInternalEvent.didFinishScrubbing.rawValue) { [weak self] _ in
                if self?.hideControlsTimer?.isValid ?? false {
                    self?.disappearAfterSomeTime()
                }
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
                                                 target: self, selector: #selector(GloboMediaControl.hideAndStopTimer), userInfo: nil, repeats: false)
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
        view.backgroundColor = UIColor.steveBlack60Color()

        loadPlugins()
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

}

extension GloboMediaControl: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if seekbarTouched(touch) {
            preventViewControllerSwipeToBack()
            return false
        } else {
            return true
        }
    }

    private func preventViewControllerSwipeToBack() {
        if let seekbar = plugins.first(where: { $0.pluginName == Seekbar.name }) as? Seekbar {
            seekbar.preventViewControllerSwipeToBack()
        }
    }

    private func seekbarTouched(_ touch: UITouch) -> Bool {
        if let seekbar = plugins.first(where: { $0.pluginName == Seekbar.name })?.view,
            seekbar.frame.contains(touch.location(in: seekbar)) {
            return true
        }
        return false
    }
}
