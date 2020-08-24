import Foundation

open class MediaControl: UICorePlugin, UIGestureRecognizerDelegate {
    open class override var name: String { "MediaControl" }

    public var tapGesture: UITapGestureRecognizer?
    var mediaControlView: MediaControlView = .fromNib()

    public var hideControlsTimer: Timer?
    private var isTimerValid: Bool { hideControlsTimer?.isValid ?? false }
    public var shortTimeToHideMediaControl = 0.3
    public var longTimeToHideMediaControl = 3.0
    public var showDuration = ClapprAnimationDuration.mediaControlShow
    public var hideDuration = ClapprAnimationDuration.mediaControlHide
    private var animationState: MediaControl.AnimationState = .none
    
    var options: Options? { core?.options }
    private var alwaysVisible: Bool { core?.options.bool(kMediaControlAlwaysVisible) ?? false }
    private var isChromeless: Bool { core?.options.bool(kChromeless) ?? false }
    private var isDrawerActive = false
    private var controlsEnabled = true
    private let statesToKeepVisible: [PlaybackState] = [.paused, .idle]
    private var shouldDisappearAfterSomeTime: Bool {
        guard let state = activePlayback?.state else { return false }
        return !statesToKeepVisible.contains(state)
    }
    
    private var canHide: Bool { animationState != .hiding && !alwaysVisible }
    private var canShow: Bool { !isChromeless
        && animationState != .showing
        && !isDrawerActive
        && controlsEnabled
    }

    override open func bindEvents() {
        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    open func bindCoreEvents() {
        guard let core = core else { return }

        listenTo(core, event: .requestPadding) { [weak self] info in
            self?.onPaddingRequested(info: info)
        }

        listenTo(core, eventName: InternalEvent.didTappedCore.rawValue) { [weak self] _ in
            self?.showOnTap()
        }

        listenToFullscreenEvents(context: core)
        listenToScrubbingEvents(context: core)
        listenToDrawerEvents(context: core)
    }

    private func bindContainerEvents() {
        guard let container = activeContainer else { return }

        listenTo(container, event: Event.enableMediaControl) { [weak self] _ in self?.show(animated: true) }
        listenTo(container, event: Event.disableMediaControl) { [weak self] _ in self?.hide(animated: true) }
    }

    private func bindPlaybackEvents() {
        guard let playback = activePlayback else { return }

        listenTo(playback, event: .ready) { [weak self] _ in self?.controlsEnabled = true }
        listenTo(playback, event: .error) { [weak self] _ in self?.controlsEnabled = false }

        listenToOnce(playback, event: .playing) { [weak self] _ in
            self?.showIfAlwaysVisible()
        }

        listenTo(playback, event: .didPause) { [weak self] _ in self?.onPause() }
        listenTo(playback, event: .didComplete) { [weak self] _ in self?.onComplete() }
    }

    private func listenToFullscreenEvents(context: UIObject) {
        listenTo(context, event: .didEnterFullscreen) { [weak self] _ in self?.onFullscreenStateChanged() }
        listenTo(context, event: .didExitFullscreen) { [weak self] _ in self?.onFullscreenStateChanged() }
    }

    private func listenToScrubbingEvents(context: UIObject) {
        listenTo(context, eventName: InternalEvent.willBeginScrubbing.rawValue) { [weak self] _ in
            self?.keepVisible()
        }

        listenTo(context, eventName: InternalEvent.didFinishScrubbing.rawValue) { [weak self] _ in
            self?.onScrubbingFinished()
        }
    }

    private func listenToDrawerEvents(context: UIObject) {
        listenTo(context, eventName: InternalEvent.didDragDrawer.rawValue) { [weak self] info in
            self?.onDrawerDragged(info: info)
        }

        listenTo(context, event: .didShowDrawerPlugin) { [weak self] _ in self?.onDrawerShowed() }
        listenTo(context, event: .didHideDrawerPlugin) { [weak self] _ in self?.onDrawerHidden() }
    }
    
    private func showIfAlwaysVisible() {
        show(animated: true) {
            guard !self.alwaysVisible else { return }
            self.disappearAfterSomeTime(self.longTimeToHideMediaControl)
        }
    }

    private func showOnTap() {
        show(animated: true) {
            guard self.shouldDisappearAfterSomeTime else { return }
            self.disappearAfterSomeTime(self.longTimeToHideMediaControl)
        }
    }
    
    private func onPaddingRequested(info: EventUserInfo) {
        guard let padding = info?["padding"] as? CGFloat else { return }

        mediaControlView.bottomPadding.constant = padding
    }
    
    private func onPause() {
        keepVisible()
        resetTimerOnPlay()
    }
    
    private func onComplete() {
        guard !isDrawerActive else { return }

        show(animated: true)
        keepVisible()
        resetTimerOnPlay()
    }
    
    private func onFullscreenStateChanged() {
        guard isTimerValid else { return }

        disappearAfterSomeTime()
    }
    
    private func onScrubbingFinished() {
        guard shouldDisappearAfterSomeTime else { return }

        disappearAfterSomeTime()
    }
    
    private func onDrawerDragged(info: EventUserInfo) {
        guard let alpha = info?["alpha"] as? CGFloat else { return }

        view.alpha = alpha
    }
    
    private func onDrawerShowed() {
        isDrawerActive = true
        hide(animated: true)
    }
    
    private func onDrawerHidden() {
        let statesToShow: [PlaybackState] = [.paused, .idle]
        isDrawerActive = false
        
        guard let state = activePlayback?.state else { return }

        if state == .playing {
            show(animated: true) { self.disappearAfterSomeTime() }
        } else if statesToShow.contains(state) {
            show(animated: true)
            keepVisible()
            resetTimerOnPlay()
        }
    }

    private func resetTimerOnPlay() {
        guard let playback = activePlayback else { return }

        listenToOnce(playback, event: .playing) { [weak self] _ in
            self?.disappearAfterSomeTime()
        }
    }
    
    public func disappearAfterSomeTime(_ duration: TimeInterval? = nil) {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: duration ?? shortTimeToHideMediaControl,
                                                 target: self, selector: #selector(hideAndStopTimer), userInfo: nil, repeats: false)
    }

    public func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        if !canShow {
            completion?()
            return
        }
        
        core?.trigger(Event.willShowMediaControl.rawValue)
        animationState = .showing

        let duration = animated ? showDuration : 0

        self.view.isHidden = false
        animate(alpha: 1, options: .curveEaseOut, duration: duration) {
            self.animationState = .none
            self.core?.trigger(Event.didShowMediaControl.rawValue)
            completion?()
        }
    }

    func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
        if !canHide {
            completion?()
            return
        }
        
        core?.trigger(Event.willHideMediaControl.rawValue)
        animationState = .hiding
        
        let duration = animated ? hideDuration : 0
        animate(alpha: 0, options: .curveEaseIn, duration: duration) {
            self.view.isHidden = true
            self.animationState = .none
            self.core?.trigger(Event.didHideMediaControl.rawValue)
            completion?()
        }
    }
    
    private func animate(alpha: CGFloat, options: UIView.AnimationOptions = [], duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: {
                self.view.alpha = alpha
        },
            completion: { _ in completion?() }
        )
    }

    public func keepVisible() {
        hideControlsTimer?.invalidate()
    }

    @objc func hideAndStopTimer() {
        hideControlsTimer?.invalidate()
        hide(animated: true)
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideAndStopTimer))
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
        guard let superview = view.superview else { return }
        
        view.addSubview(mediaControlView)
        mediaControlView.constrainBounds(to: view)
        
        setupGestureRecognizer()
        setupViews()

        view.constrainBounds(to: superview)
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

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !seekbarWasTouched(touch)
    }

    open func seekbarWasTouched(_ touch: UITouch) -> Bool {
        let seekbar = core?.plugins.first { $0.pluginName == Seekbar.name }
        if let seekbar = seekbar as? MediaControl.Element,
            seekbar.view.frame.contains(touch.location(in: seekbar.view)) {
            return true
        }

        return false
    }
}
