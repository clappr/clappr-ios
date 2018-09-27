open class Player: BaseObject {

    @objc open var playbackEventsToListen: [String] = []
    fileprivate var playbackEventsListenIds: [String] = []
    @objc fileprivate(set) open var core: Core?

    @objc open var activeContainer: Container? {
        return core?.activeContainer
    }

    @objc open var activePlayback: Playback? {
        return core?.activePlayback
    }

    @objc open var isFullscreen: Bool {
        guard let core = self.core else {
            return false
        }

        return core.isFullscreen
    }

    @objc open var isPlaying: Bool {
        return activePlayback?.isPlaying ?? false
    }

    @objc open var isPaused: Bool {
        return activePlayback?.isPaused ?? false
    }

    @objc open var isBuffering: Bool {
        return activePlayback?.isBuffering ?? false
    }

    @objc open var duration: Double {
        return activePlayback?.duration ?? 0
    }

    @objc open var position: Double {
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
             Event.requestFullscreen.rawValue, Event.exitFullscreen.rawValue,
             Event.positionUpdate.rawValue, Event.willPlay.rawValue,
             Event.willPause.rawValue, Event.willStop.rawValue,
             Event.airPlayStatusUpdate.rawValue, Event.willSeek.rawValue,
             Event.seek.rawValue, Event.didSeek.rawValue,
             Event.subtitleSelected.rawValue, Event.audioSelected.rawValue])

        Loader.shared.addExternalPlugins(externalPlugins)
        
        setCore(Core(options: options))
    }

    fileprivate func setCore(_ core: Core) {
        self.core?.stopListening()

        self.core = core

        self.core?.on(InternalEvent.willChangeActivePlayback.rawValue) { [weak self] _ in self?.unbindPlaybackEvents() }
        self.core?.on(InternalEvent.didChangeActivePlayback.rawValue) { [weak self] _ in self?.bindPlaybackEvents() }
        self.core?.on(InternalEvent.userRequestEnterInFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.requestFullscreen, userInfo: info) }
        self.core?.on(InternalEvent.userRequestExitFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.exitFullscreen, userInfo: info) }

        bindPlaybackEvents()
    }

    @objc open func attachTo(_ view: UIView, controller: UIViewController) {
        core?.parentController = controller
        core?.parentView = view
        core?.render()
    }

    @objc open func load(_ source: String, mimeType: String? = nil) {
        core?.activeContainer?.load(source, mimeType: mimeType)
        play()
    }

    @objc open func configure(options: Options) {
        core?.options = options
    }

    @objc open func play() {
        core?.activePlayback?.play()
    }

    @objc open func pause() {
        core?.activePlayback?.pause()
    }

    @objc open func stop() {
        core?.activePlayback?.stop()
    }

    @objc open func seek(_ timeInterval: TimeInterval) {
        core?.activePlayback?.seek(timeInterval)
    }

    @objc open func setFullscreen(_ fullscreen: Bool) {
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

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Player")
        stopListening()
        Logger.logDebug("destroying core", scope: "Player")
        self.core?.destroy()
        self.core = nil
        Logger.logDebug("destroyed", scope: "Player")
    }
}
