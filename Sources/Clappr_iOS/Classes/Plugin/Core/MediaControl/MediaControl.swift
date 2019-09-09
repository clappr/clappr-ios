import Foundation

open class MediaControl: UICorePlugin, UIGestureRecognizerDelegate {

    public var tapGesture: UITapGestureRecognizer?
    private let paddingHeight: CGFloat = 32.0

    var mediaControlView: MediaControlView = .fromNib()

    var options: Options? {
        return core?.options
    }

    open class override var name: String {
        return "MediaControl"
    }

    public var hideControlsTimer: Timer?
    public var shortTimeToHideMediaControl = 0.4
    public var longTimeToHideMediaControl = 4.0
    public var mediaControlShow = ClapprAnimationDuration.mediaControlShow
    public var mediaControlHide = ClapprAnimationDuration.mediaControlHide

    private var showControls = true
    private var alwaysVisible = false
    private var currentlyShowing = false
    private var currentlyHiding = false

    required public init(context: UIObject) {
        super.init(context: context)
        alwaysVisible = (core?.options[kMediaControlAlwaysVisible] as? Bool) ?? false
    }

    override open func bindEvents() {
        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    open func bindCoreEvents() {
        guard let core = core else { return }

        listenFullscreenEvents()

        listenTo(core, event: .requestPadding) { [weak self] info in
            guard let padding = info?["padding"] as? CGFloat else { return }
            self?.mediaControlView.bottomPadding.constant = padding
        }

        listenTo(core, eventName: InternalEvent.didTappedCore.rawValue) { [weak self] _ in
            self?.toggleVisibility()
        }

        listenScrubbingEvents()
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
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in
                self?.showControls = true
            }

            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in
                self?.hide()
            }

            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in
                self?.keepVisible()
                self?.listenToOnce(playback, eventName: Event.playing.rawValue) { [weak self] _ in
                    self?.show { [weak self] in
                        self?.disappearAfterSomeTime()
                    }
                }
            }

            listenTo(playback, eventName: Event.error.rawValue) { [weak self] _ in
                self?.showControls = false
            }
        }
    }

    private func listenFullscreenEvents() {
        guard let core = core else { return }

        listenTo(core, eventName: Event.didEnterFullscreen.rawValue) { [weak self] _ in
            if self?.hideControlsTimer?.isValid ?? false {
                self?.disappearAfterSomeTime()
            }
        }

        listenTo(core, eventName: Event.didExitFullscreen.rawValue) { [weak self] _ in
            if self?.hideControlsTimer?.isValid ?? false {
                self?.disappearAfterSomeTime()
            }
        }
    }

    private func listenScrubbingEvents() {
        guard let core = core else { return }

        listenTo(core, eventName: InternalEvent.willBeginScrubbing.rawValue) { [weak self] _ in
            self?.keepVisible()
        }

        listenTo(core, eventName: InternalEvent.didFinishScrubbing.rawValue) { [weak self] _ in
            guard self?.activePlayback?.state == .playing else { return }
            self?.disappearAfterSomeTime()
        }
    }

    func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentlyShowing {
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
    
    override open func render() {
        view.addSubview(mediaControlView)
        mediaControlView.bindFrameToSuperviewBounds()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        if let constrastView = mediaControlView.contrastView {
            constrastView.backgroundColor = UIColor.clapprBlack60Color()
        }

        showIfAlwaysVisible()
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
        if let elementsOrder = core?.options[kMediaControlElementsOrder] as? [String] {
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

        return elements
    }

    private func showIfAlwaysVisible() {
        if alwaysVisible {
            show()
        }
    }

    fileprivate func toggleVisibility() {
        if showControls {
            show(animated: true) { [weak self] in
                self?.disappearAfterSomeTime(self?.longTimeToHideMediaControl)
            }
        }
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
