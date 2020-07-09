import Foundation

open class MediaControl: UICorePlugin, UIGestureRecognizerDelegate {
    open class override var name: String { "MediaControl" }

    public var tapGesture: UITapGestureRecognizer?
    var mediaControlView: MediaControlView = .fromNib()

    public var hideControlsTimer: Timer?
    public var shortTimeToHideMediaControl = 0.4
    public var longTimeToHideMediaControl = 4.0
    public var mediaControlShow = ClapprAnimationDuration.mediaControlShow
    public var mediaControlHide = ClapprAnimationDuration.mediaControlHide

    private var alwaysVisible = false
    private var currentlyShowing = false
    private var currentlyHiding = false
    private var isDrawerActive = false
    private var isChromeless: Bool { core?.options.bool(kChromeless) ?? false }
    private var controlsEnabled = true

    var options: Options? { core?.options }
    private var alwaysVisible: Bool { core?.options.bool(kMediaControlAlwaysVisible) ?? false }

    override open func bindEvents() {
        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    open func bindCoreEvents() {
        guard let core = core else { return }

        listenFullscreenEvents(context: core)

        listenTo(core, event: .requestPadding) { [weak self] info in
            guard let padding = info?["padding"] as? CGFloat else { return }
            self?.mediaControlView.bottomPadding.constant = padding
        }

        listenTo(core, eventName: InternalEvent.didTappedCore.rawValue) { [weak self] _ in
            self?.toggleVisibility()
        }

        listenScrubbingEvents(context: core)

        listenDrawerEvents(context: core)
    }

    private func bindContainerEvents() {
        if let container = activeContainer {
            listenTo(container,
                     eventName: Event.enableMediaControl.rawValue) { [weak self] _ in self?.show() }
            listenTo(container,
                     eventName: Event.disableMediaControl.rawValue) { [weak self] _ in self?.hide() }
        }
    }

    private func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, event: .ready) { [weak self] _ in
                self?.controlsEnabled = true
            }
            
            listenToOnce(playback, event: .playing) { [weak self] _ in
                self?.showIfAlwaysVisible()
            }

            listenTo(playback, event: .didComplete) { [weak self] _ in
                self?.onComplete()
                self?.listenToOnce(playback, event: .playing) { [weak self] _ in
                    self?.show {
                        self?.disappearAfterSomeTime()
                    }
                }
            }

            listenTo(playback, event: .didPause) { [weak self] _ in
                self?.keepVisible()
                self?.listenToOnce(playback, event: .playing) { [weak self] _ in
                    self?.show {
                        self?.disappearAfterSomeTime()
                    }
                }
            }

            listenTo(playback, event: .error) { [weak self] _ in
                self?.controlsEnabled = false
            }
        }
    }

    private func listenFullscreenEvents(context: UIObject) {
        listenTo(context, event: .didEnterFullscreen) { [weak self] _ in
            if self?.hideControlsTimer?.isValid ?? false {
                self?.disappearAfterSomeTime()
            }
        }

        listenTo(context, event: .didExitFullscreen) { [weak self] _ in
            if self?.hideControlsTimer?.isValid ?? false {
                self?.disappearAfterSomeTime()
            }
        }
    }

    private func listenScrubbingEvents(context: UIObject) {
        listenTo(context, eventName: InternalEvent.willBeginScrubbing.rawValue) { [weak self] _ in
            self?.keepVisible()
        }

        listenTo(context, eventName: InternalEvent.didFinishScrubbing.rawValue) { [weak self] _ in
            guard self?.activePlayback?.state == .playing else { return }
            self?.disappearAfterSomeTime()
        }
    }

    private func listenDrawerEvents(context: UIObject) {
        listenTo(context, eventName: InternalEvent.didDragDrawer.rawValue) { [weak self] info in
            guard let alpha = info?["alpha"] as? CGFloat else { return }
            self?.view.alpha = alpha
        }

        listenTo(context, event: .didShowDrawerPlugin) { [weak self] _ in
            self?.isDrawerActive = true
            self?.hide()
        }

        listenTo(context, event: .didHideDrawerPlugin) { [weak self] _ in
            let statesToShow: [PlaybackState] = [.playing, .paused, .idle]
            self?.isDrawerActive = false

            guard let state = self?.activePlayback?.state, statesToShow.contains(state) else { return }
            self?.show()
        }
    }
    
    func onComplete() {
        guard !isDrawerActive else { return }
        keepVisible()
        show()
    }

    func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentlyShowing || isChromeless {
            completion?()
            return
        }

        let duration = animated ? mediaControlShow : 0

        currentlyShowing = true
        currentlyHiding = false

        core?.trigger(Event.willShowMediaControl.rawValue)

        if view.alpha == 0 {
            view.isHidden = false
        }

        UIView.animate(
            withDuration: duration,
            animations: {
                self.view.alpha = 1
        },
            completion: { [weak self] _ in
                self?.view.isHidden = false
                self?.currentlyShowing = false
                self?.core?.trigger(Event.didShowMediaControl.rawValue)
                completion?()
            }
        )
    }

    func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentlyHiding {
            completion?()
            return
        }

        if !alwaysVisible {
            core?.trigger(Event.willHideMediaControl.rawValue)

            currentlyShowing = false
            currentlyHiding = true

            let duration = animated ? mediaControlHide : 0

            UIView.animate(
                withDuration: duration,
                animations: {
                    self.view.alpha = 0
            },
                completion: { [weak self] _ in
                    self?.currentlyHiding = false
                    self?.view.isHidden = true
                    self?.core?.trigger(Event.didHideMediaControl.rawValue)
                    completion?()
                }
            )
        }
    }

    public func disappearAfterSomeTime(_ duration: TimeInterval? = nil) {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: duration ?? shortTimeToHideMediaControl,
                                                 target: self, selector: #selector(hideAndStopTimer), userInfo: nil, repeats: false)
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
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
    
    private func setupViews() {
        view.isHidden = true
        view.alpha = 0
        view.backgroundColor = UIColor.clear
        if let constrastView = mediaControlView.contrastView {
            constrastView.backgroundColor = UIColor.clapprBlack60Color()
        }
    }
    
    override open func render() {
        view.addSubview(mediaControlView)
        mediaControlView.bindFrameToSuperviewBounds()
        
        setupGestureRecognizer()
        setupViews()

        view.bindFrameToSuperviewBounds()
    }

    func render(_ elements: [MediaControl.Element]) {
        let orderedElements = sortElementsIfNeeded(elements)
        orderedElements.forEach { element in
            mediaControlView.addSubview(element.view, in: element.panel, at: element.position)

            do {
                try ObjC.catchException {
                    element.render()
                }
            } catch {
                Logger.logError("\((element as Plugin).pluginName) crashed during render (\(error.localizedDescription))", scope: "MediaControl")
            }
        }
    }

    private func sortElementsIfNeeded(_ elements: [MediaControl.Element]) -> [MediaControl.Element] {
        guard let elementsOrder = core?.options[kMediaControlElementsOrder] as? [String] else {
            return elements
        }
        var orderedElements = [MediaControl.Element]()
        elementsOrder.forEach { elementName in
            if let selectedElement = elements.first(where: { $0.pluginName == elementName }) {
                orderedElements.append(selectedElement)
            } else {
                Logger.logInfo("Element \(elementName) not found.")
            }
        }
        orderedElements.append(contentsOf: elements.filter { !elementsOrder.contains($0.pluginName) })
        
        return orderedElements
    }

    private func showIfAlwaysVisible() {
        guard alwaysVisible else { return }
        
        show()
    }

    private func toggleVisibility() {
        guard controlsEnabled else { return }
        
        show(animated: true) {
            self.disappearAfterSomeTime(self.longTimeToHideMediaControl)
        }
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
