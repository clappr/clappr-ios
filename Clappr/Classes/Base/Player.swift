open class Player: BaseObject {

    open var playbackEventsToListen: [String] = []
    fileprivate var playbackEventsListenIds: [String] = []
    fileprivate(set) open var core: Core?

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
        super.init()

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

    open func attachTo(_ view: UIView, controller: UIViewController) {
        core?.parentController = controller
        core?.parentView = view
        core?.render()
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

    open func setScreen(state: ScreenState) {
        core?.setScreen(state: state)
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
}
