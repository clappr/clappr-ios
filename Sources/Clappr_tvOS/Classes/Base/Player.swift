import AVKit

open class Player: UIViewController, BaseObject {
    open var playbackEventsToListen: [String] = []
    fileprivate var playbackEventsListenIds: [String] = []
    fileprivate(set) open var core: Core?
    static var hasAlreadyRegisteredPlaybacks = false
    fileprivate var viewController: AVPlayerViewController?

    override open func viewDidLoad() {
        core?.parentView = view

        if isMediaControlEnabled != false {
            viewController = AVPlayerViewController()
            core?.parentView = viewController?.contentOverlayView
            core?.parentController = self
            if let vc = viewController {
                addChild(vc)
                vc.view.frame = view.bounds
                vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.addSubview(vc.view)
                vc.didMove(toParent: self)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(Player.willEnterForeground), name:
            UIApplication.willEnterForegroundNotification, object: nil)

        core?.render()
    }

    open var isMediaControlEnabled: Bool {
        return core?.options[kMediaControl] as? Bool ?? false
    }

    @objc fileprivate func willEnterForeground() {
        if let playback = activePlayback as? AVFoundationPlayback, !isMediaControlEnabled {
            Logger.logDebug("forced play after return from background", scope: "Player")
            playback.play()
        }
    }

    open var activeContainer: Container? {
        return core?.activeContainer
    }

    open var activePlayback: Playback? {
        return core?.activePlayback
    }

    open var isFullscreen: Bool {
        guard let core = self.core else {
            return false
        }

        return core.isFullscreen
    }

    open var isPlaying: Bool {
        return activePlayback?.isPlaying ?? false
    }

    open var isPaused: Bool {
        return activePlayback?.isPaused ?? false
    }

    open var isBuffering: Bool {
        return activePlayback?.isBuffering ?? false
    }

    open var duration: Double {
        return activePlayback?.duration ?? 0
    }

    open var position: Double {
        return activePlayback?.position ?? 0
    }

    open var subtitles: [MediaOption]? {
        return activePlayback?.subtitles
    }

    open var audioSources: [MediaOption]? {
        return activePlayback?.audioSources
    }

    open var selectedSubtitle: MediaOption? {
        get {
            return activePlayback?.selectedSubtitle
        }
        set {
            activePlayback?.selectedSubtitle = newValue
        }
    }

    open var selectedAudioSource: MediaOption? {
        get {
            return activePlayback?.selectedAudioSource
        }
        set {
            activePlayback?.selectedAudioSource = newValue
        }
    }

    public init(options: Options = [:], externalPlugins: [Plugin.Type] = []) {
        super.init(nibName: nil, bundle: nil)

        Player.register(playbacks: [])
        Player.register(plugins: externalPlugins)

        Logger.logInfo("loading with \(options)", scope: "Clappr")

        self.playbackEventsToListen.append(contentsOf:
            [Event.ready.rawValue, Event.error.rawValue,
             Event.playing.rawValue, Event.didComplete.rawValue,
             Event.didPause.rawValue, Event.stalling.rawValue,
             Event.didStop.rawValue, Event.didUpdateBuffer.rawValue,
             Event.willPlay.rawValue, Event.didUpdatePosition.rawValue,
             Event.willPause.rawValue, Event.willStop.rawValue,
             Event.willSeek.rawValue, Event.didUpdateAirPlayStatus.rawValue,
             Event.didSeek.rawValue,
             Event.didFindSubtitle.rawValue, Event.didFindAudio.rawValue,
             Event.didSelectSubtitle.rawValue, Event.didSelectAudio.rawValue,])

        setCore(with: options)
        
        bindPlaybackEvents()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setCore(with options: Options) {
        self.core = CoreFactory.create(with: options)
        bindCoreEvents()
    }
    
    fileprivate func bindCoreEvents() {
        self.core?.on(Event.willChangeActivePlayback.rawValue) { [weak self] _ in self?.unbindPlaybackEvents() }
        self.core?.on(Event.didChangeActivePlayback.rawValue) { [weak self] _ in self?.bindPlaybackEvents() }
        self.core?.on(Event.didEnterFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.requestFullscreen, userInfo: info) }
        self.core?.on(Event.didExitFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.exitFullscreen, userInfo: info) }

        self.core?.render()
    }

    open func load(_ source: String, mimeType: String? = nil) {
        core?.activeContainer?.load(source, mimeType: mimeType)
        play()
    }

    open func configure(options: Options) {
        core?.options = options
    }

    open func play() {
        core?.activePlayback?.play()
    }

    open func pause() {
        core?.activePlayback?.pause()
    }

    open func stop() {
        core?.activePlayback?.stop()
    }

    open func seek(_ timeInterval: TimeInterval) {
        core?.activePlayback?.seek(timeInterval)
    }

    open func mute(enabled: Bool) {
        core?.activePlayback?.mute(enabled)
    }

    open func setFullscreen(_ fullscreen: Bool) {
        core?.setFullscreen(fullscreen)
    }

    @discardableResult
    open func on(_ event: Event, callback: @escaping EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }

    fileprivate func bindPlaybackEvents() {
        if let playback = core?.activePlayback {
            for event in playbackEventsToListen {
                let listenId = listenTo(
                    playback, eventName: event,
                    callback: { [weak self] (info: EventUserInfo) in
                        self?.trigger(event, userInfo: info)
                })

                playbackEventsListenIds.append(listenId)
            }

            let listenId = listenToOnce(playback, eventName: Event.playing.rawValue, callback: { [weak self] _ in self?.bindPlayer(playback: playback) })
            playbackEventsListenIds.append(listenId)
        }
    }

    fileprivate func bindPlayer(playback: Playback?) {
        if let avFoundationPlayback = (playback as? AVFoundationPlayback), let player = avFoundationPlayback.player {
            viewController?.player = player
            viewController?.delegate = avFoundationPlayback
        }
    }

    fileprivate func unbindPlaybackEvents() {
        for id in playbackEventsListenIds {
            stopListening(id)
        }

        playbackEventsListenIds.removeAll()
    }
    
    open class func register(playbacks: [Playback.Type]) {
        if !hasAlreadyRegisteredPlaybacks {
            Loader.shared.register(playbacks: [AVFoundationPlayback.self])
            hasAlreadyRegisteredPlaybacks = true
        }
        Loader.shared.register(playbacks: playbacks)
    }

    private class func register(plugins: [Plugin.Type]) {
        Loader.shared.register(plugins: plugins)
    }

    fileprivate func forward(_ event: Event, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }

    open func destroy() {
        Logger.logDebug("destroying", scope: "Player")
        stopListening()
        Logger.logDebug("destroying core", scope: "Player")
        self.core?.destroy()
        Logger.logDebug("destroying viewController", scope: "Player")
        destroyViewController()
        Logger.logDebug("destroyed", scope: "Player")
    }

    fileprivate func destroyViewController() {
        if let viewController = viewController {
            viewController.player = nil
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }

        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if presentedViewController == nil {
            destroy()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
