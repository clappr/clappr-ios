open class Player: BaseObject {
    open fileprivate(set) var core: Core

    open var activeContainer: Container? {
        return core.activeContainer
    }

    open var activePlayback: Playback? {
        return core.activePlayback
    }

    open var isFullscreen: Bool {
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
        let loader = Loader(externalPlugins: externalPlugins, options: options)
        self.core = CoreFactory.create(loader , options: options)
    }
    
    open func attachTo(_ view: UIView, controller: UIViewController) {
        bindEvents()
        core.parentController = controller
        core.parentView = view
        core.render()
    }
    
    open func load(_ source: String, mimeType: String? = nil) {
        core.container.load(source, mimeType: mimeType)
        play()
    }
    
    open func play() {
        core.container.play()
    }
    
    open func pause() {
        core.container.pause()
    }
    
    open func stop() {
        core.container.stop()
    }
    
    open func seek(_ timeInterval: TimeInterval) {
        core.container.seek(timeInterval)
    }
    
    open func setFullscreen(_ fullscreen: Bool) {
        core.setFullscreen(fullscreen)
    }
    
    open func on(_ event: PlayerEvent, callback: @escaping EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }
    
    fileprivate func bindEvents() {
        for (event, callback) in coreBindings() {
            listenTo(core, eventName: event.rawValue, callback: callback)
        }
        for (event, callback) in containerBindings() {
            listenTo(core.container, eventName: event.rawValue, callback: callback)
        }
    }

    fileprivate func coreBindings() -> [CoreEvent : EventCallback] {
        return [
            .EnterFullscreen : { [weak self] (info: EventUserInfo) in self?.forward(.enterFullscreen, userInfo: info)},
            .ExitFullscreen  : { [weak self] (info: EventUserInfo) in self?.forward(.exitFullscreen, userInfo: info)}
        ]
    }
    
    fileprivate func containerBindings() -> [ContainerEvent : EventCallback] {
        return [
            .play  : { [weak self] (info: EventUserInfo) in self?.forward(.play, userInfo: info)},
            .ready : { [weak self] (info: EventUserInfo) in self?.forward(.ready, userInfo: info)},
            .ended : { [weak self] (info: EventUserInfo) in self?.forward(.ended, userInfo: info)},
            .error : { [weak self] (info: EventUserInfo) in self?.forward(.error, userInfo: info)},
            .stop  : { [weak self] (info: EventUserInfo) in self?.forward(.stop, userInfo: info)},
            .pause : { [weak self] (info: EventUserInfo) in self?.forward(.pause, userInfo: info)}
        ]
    }
    
    fileprivate func forward(_ event: PlayerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
    
    deinit {
        stopListening()
    }
}
