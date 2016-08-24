public class Player: BaseObject {
    public private(set) var core: Core

    public var activeContainer: Container? {
        return core.activeContainer
    }

    public var activePlayback: Playback? {
        return core.activePlayback
    }

    public var isFullscreen: Bool {
        return core.isFullscreen
    }

    public var isPlaying: Bool {
        return activePlayback?.isPlaying ?? false
    }

    public var isPaused: Bool {
        return activePlayback?.isPaused ?? false
    }

    public var isBuffering: Bool {
        return activePlayback?.isBuffering ?? false
    }

    public var duration: Double {
        return activePlayback?.duration ?? 0
    }

    public var position: Double {
        return activePlayback?.position ?? 0
    }
    
    public var subtitles: [MediaOption]? {
        return activePlayback?.subtitles
    }
    
    public var audioSources: [MediaOption]? {
        return activePlayback?.audioSources
    }
    
    public var selectedSubtitle: MediaOption? {
        get {
            return activePlayback?.selectedSubtitle
        }
        set {
            activePlayback?.selectedSubtitle = newValue
        }
    }
    
    public var selectedAudioSource: MediaOption? {
        get {
            return activePlayback?.selectedAudioSource
        }
        set {
            activePlayback?.selectedAudioSource = newValue
        }
    }
    
    public init(options: Options = [:], externalPlugins: [Plugin.Type] = []) {
        Logger.logInfo("Loading with \(options)", scope: "Clappr")
        let loader = Loader(externalPlugins: externalPlugins, options: options)
        self.core = CoreFactory.create(loader , options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        bindEvents()
        core.parentController = controller
        core.parentView = view
        core.render()
    }
    
    public func load(source: String, mimeType: String? = nil) {
        core.container.load(source, mimeType: mimeType)
        play()
    }
    
    public func play() {
        core.container.play()
    }
    
    public func pause() {
        core.container.pause()
    }
    
    public func stop() {
        core.container.stop()
    }
    
    public func seek(timeInterval: NSTimeInterval) {
        core.container.seek(timeInterval)
    }
    
    public func setFullscreen(fullscreen: Bool) {
        core.setFullscreen(fullscreen)
    }
    
    public func on(event: PlayerEvent, callback: EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }
    
    private func bindEvents() {
        for (event, callback) in coreBindings() {
            listenTo(core, eventName: event.rawValue, callback: callback)
        }
        for (event, callback) in containerBindings() {
            listenTo(core.container, eventName: event.rawValue, callback: callback)
        }
    }

    private func coreBindings() -> [CoreEvent : EventCallback] {
        return [
            .EnterFullscreen : { [weak self] (info: EventUserInfo) in self?.forward(.EnterFullscreen, userInfo: info)},
            .ExitFullscreen  : { [weak self] (info: EventUserInfo) in self?.forward(.ExitFullscreen, userInfo: info)}
        ]
    }
    
    private func containerBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play  : { [weak self] (info: EventUserInfo) in self?.forward(.Play, userInfo: info)},
            .Ready : { [weak self] (info: EventUserInfo) in self?.forward(.Ready, userInfo: info)},
            .Ended : { [weak self] (info: EventUserInfo) in self?.forward(.Ended, userInfo: info)},
            .Error : { [weak self] (info: EventUserInfo) in self?.forward(.Error, userInfo: info)},
            .Stop  : { [weak self] (info: EventUserInfo) in self?.forward(.Stop, userInfo: info)},
            .Pause : { [weak self] (info: EventUserInfo) in self?.forward(.Pause, userInfo: info)}
        ]
    }
    
    private func forward(event: PlayerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
    
    deinit {
        stopListening()
    }
}