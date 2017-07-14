import AVKit

open class Player: UIViewController, EventProtocol {
    open var playbackEventsToListen: [String] = []
    fileprivate var playbackEventsListenIds: [String] = []
    fileprivate(set) open var core: Core?
    fileprivate var viewController: AVPlayerViewController?
    fileprivate let base = BaseObject()

    override open func viewDidLoad() {
        core?.parentView = view
        core?.render()

        if core?.options[kMediaControl] as? Bool != false {
            viewController = AVPlayerViewController()
            if let vc = viewController {
                addChildViewController(vc)
                vc.view.frame = view.bounds
                vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.addSubview(vc.view)
                vc.didMove(toParentViewController: self)
            }
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

        Logger.logInfo("loading with \(options)", scope: "Clappr")

        self.playbackEventsToListen.append(contentsOf:
            [Event.ready.rawValue, Event.error.rawValue,
             Event.playing.rawValue, Event.didComplete.rawValue,
             Event.didPause.rawValue, Event.stalled.rawValue,
             Event.didStop.rawValue, Event.bufferUpdate.rawValue,
             Event.positionUpdate.rawValue, Event.willPlay.rawValue,
             Event.willPause.rawValue, Event.willStop.rawValue,
             Event.airPlayStatusUpdate.rawValue, Event.seek.rawValue])

        let loader = Loader(externalPlugins: externalPlugins, options: options)

        setCore(Core(loader: loader, options: options))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setCore(_ core: Core) {
        self.core?.stopListening()

        self.core = core

        self.core?.on(InternalEvent.willChangeActivePlayback.rawValue) { [weak self] _ in self?.unbindPlaybackEvents() }
        self.core?.on(InternalEvent.didChangeActivePlayback.rawValue) { [weak self] _ in self?.bindPlaybackEvents() }
        self.core?.on(InternalEvent.didEnterFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.requestFullscreen, userInfo: info) }
        self.core?.on(InternalEvent.didExitFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.exitFullscreen, userInfo: info) }

        bindPlaybackEvents()

        self.core?.render()
    }

    open func load(_ source: String, mimeType: String? = nil) {
        core?.activeContainer?.load(source, mimeType: mimeType)
        play()
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
        if let player = (playback as? AVFoundationPlayback)?.player {
            viewController?.player = player
        }
    }

    fileprivate func unbindPlaybackEvents() {
        for id in playbackEventsListenIds {
            stopListening(id)
        }

        playbackEventsListenIds.removeAll()
    }

    fileprivate func forward(_ event: Event, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }

    open func destroy() {
        Logger.logDebug("destroying", scope: "Player")
        stopListening()
        Logger.logDebug("destroying core", scope: "Player")
        self.core?.destroy()
        Logger.logDebug("destroyed", scope: "Player")
    }

    public func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return base.on(eventName, callback: callback)
    }

    public func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return base.once(eventName, callback: callback)
    }

    public func off(_ listenId: String) {
        base.off(listenId)
    }

    public func trigger(_ eventName: String) {
        base.trigger(eventName)
    }

    public func trigger(_ eventName: String, userInfo: [AnyHashable : Any]?) {
        base.trigger(eventName, userInfo: userInfo)
    }

    public func listenTo<T>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String where T : EventProtocol {
        return base.listenTo(contextObject, eventName: eventName, callback: callback)
    }

    public func listenToOnce<T>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String where T : EventProtocol {
        return base.listenToOnce(contextObject, eventName: eventName, callback: callback)
    }

    public func stopListening() {
        base.stopListening()
    }

    public func stopListening(_ listenId: String) {
        base.stopListening(listenId)
    }

    public func getEventContextObject() -> BaseObject {
        return base.getEventContextObject()
    }
}
