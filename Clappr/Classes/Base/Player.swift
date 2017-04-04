open class Player: BaseObject {
    open fileprivate(set) var core: Core?
    
    fileprivate var playbackEventsToListen: [Event]
    fileprivate var playbackEventsListenIds: [String] = []

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
        Logger.logInfo("loading with \(options)", scope: "Clappr")
        self.playbackEventsToListen = [
            .ready, .error,
            .playing, .didComplete,
            .didPause, .stalled,
            .didStop, .bufferUpdate,
            .positionUpdate, .willPlay,
            .willPause, .willStop,
            .airPlayStatusUpdate]
        
        super.init()
        
        let loader = Loader(externalPlugins: externalPlugins, options: options)
        let core = Core(loader: loader , options: options)
        
        setCore(core)
    }
    
    fileprivate func setCore(_ core: Core) {
        self.core?.stopListening()
        
        self.core = core
        
        self.core?.on(InternalEvent.willChangeActivePlayback.rawValue) { [weak self] _ in self?.unbindPlaybackEvents() }
        self.core?.on(InternalEvent.didChangeActivePlayback.rawValue) { [weak self] _ in self?.bindPlaybackEvents() }
        self.core?.on(InternalEvent.didEnterFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.requestFullscreen, userInfo: info) }
        self.core?.on(InternalEvent.didExitFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.forward(.exitFullscreen, userInfo: info) }
        
        bindPlaybackEvents()
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
                let listenId = listenTo(playback, eventName: event.rawValue,
                                        callback: { [weak self] (info: EventUserInfo) in
                                            self?.trigger(event.rawValue, userInfo: info)
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
    
    deinit {
        stopListening()
    }
}
