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
    
    open func on(_ event: PlayerEvent, callback: EventCallback) -> String {
        return on(PlayerEvent(rawValue: event.rawValue)!, callback: callback)
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
            .EnterFullscreen : { [weak self] (info: EventUserInfo) in self?.forward(.EnterFullscreen, userInfo: info)},
            .ExitFullscreen  : { [weak self] (info: EventUserInfo) in self?.forward(.ExitFullscreen, userInfo: info)}
        ]
    }
    
    fileprivate func containerBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play  : { [weak self] (info: EventUserInfo) in self?.forward(.Play, userInfo: info)},
            .Ready : { [weak self] (info: EventUserInfo) in self?.forward(.Ready, userInfo: info)},
            .Ended : { [weak self] (info: EventUserInfo) in self?.forward(.Ended, userInfo: info)},
            .Error : { [weak self] (info: EventUserInfo) in self?.forward(.Error, userInfo: info)},
            .Stop  : { [weak self] (info: EventUserInfo) in self?.forward(.Stop, userInfo: info)},
            .Pause : { [weak self] (info: EventUserInfo) in self?.forward(.Pause, userInfo: info)}
        ]
    }
    
    fileprivate func forward(_ event: PlayerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
    
    deinit {
        stopListening()
    }
}
