@objcMembers
open class Player: BaseObject {

    private var layerComposer = LayerComposer()
    open var playbackEventsToListen: [String] = []
    private var playbackEventsListenIds: [String] = []
    public private(set) var core: Core?
    public var chromelessMode: Bool {
        get { core?.chromelessMode ?? false }
        set {
            core?.chromelessMode = newValue
        }
    }
    static var hasAlreadyRegisteredPlugins = false
    static var hasAlreadyRegisteredPlaybacks = false

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

    open var state: PlaybackState {
        return activePlayback?.state ?? .none
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

    public init(options: Options = [:]) {
        super.init()
        Player.register(playbacks: [])
        Player.register(plugins: [])
        Logger.logInfo("loading with \(options)", scope: "Clappr")

        self.playbackEventsToListen.append(contentsOf:
            [Event.ready.rawValue, Event.playing.rawValue,
             Event.didComplete.rawValue, Event.didPause.rawValue,
             Event.stalling.rawValue, Event.didStop.rawValue,
             Event.didUpdateBuffer.rawValue, Event.willPlay.rawValue,
             Event.didUpdatePosition.rawValue, Event.willPause.rawValue,
             Event.willStop.rawValue, Event.willSeek.rawValue,
             Event.didUpdateAirPlayStatus.rawValue, Event.didSeek.rawValue,
             Event.didFindSubtitle.rawValue, Event.didFindAudio.rawValue,
             Event.didSelectSubtitle.rawValue, Event.didSelectAudio.rawValue,
             Event.didUpdateBitrate.rawValue])

        setCore(with: options)
        bindCoreEvents()
        bindMediaControlEvents()
        bindPlaybackEvents()
        bindNotifications()
        core?.load()
    }
    
    private func setCore(with options: Options) {
        core?.stopListening()
        core = CoreFactory.create(with: options, layerComposer: layerComposer)
    }

    private func bindCoreEvents() {
        guard let core = core else { return }

        listenTo(core, event: .willChangeActivePlayback) { [weak self] _ in self?.unbindPlaybackEvents() }
        listenTo(core, event: .didChangeActivePlayback) { [weak self] _ in self?.bindPlaybackEvents() }

        listenTo(core, eventName: InternalEvent.userRequestEnterInFullscreen.rawValue) { [weak self] userInfo in self?.trigger(.requestFullscreen, userInfo: userInfo)
        }
        listenTo(core, eventName: InternalEvent.userRequestExitFullscreen.rawValue) { [weak self] userInfo in self?.trigger(.exitFullscreen, userInfo: userInfo)
        }
        listenTo(core, eventName: InternalEvent.requestDestroyPlayer.rawValue) { [weak self] _ in
            self?.destroy()
        }
    }
    
    private func bindMediaControlEvents() {
        let eventsToListen = [Event.willShowMediaControl, .didShowMediaControl, .willHideMediaControl, .didHideMediaControl]
        
        eventsToListen.forEach { event in
            core?.on(event.rawValue) { [weak self] _ in self?.trigger(event.rawValue) }
        }
    }
    
    private func bindNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(Player.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func willEnterForeground() {
        if chromelessMode {
            Logger.logDebug("forced play after return from background", scope: "Player")
            play()
        }
    }
    
    
    
    public func enterChromelessMode() {
        core?.enterChromelessMode()
    }

    public func exitChromelessMode() {
        core?.exitChromelessMode()
    }
    
    open func presentFullscreenIn(_ controller: UIViewController) {
        guard let coreView = core?.view else { return }
        controller.view.addSubviewMatchingConstraints(coreView)
    }
    
    open func fitParentView() {
        guard let coreView = core?.view else { return }
        core?.parentView?.addSubviewMatchingConstraints(coreView)
    }
    
    open func attachTo(_ view: UIView, controller: UIViewController) {
        core?.attach(to: view, controller: controller)
        core?.render()
    }

    open func load(_ source: String, mimeType: String? = nil) {
        guard let core = core else { return }
        let newOptions = core.options.merging([kSourceUrl: source, kMimeType: mimeType as Any], uniquingKeysWith: { _, second in second })
        configure(options: newOptions)
        play()
    }

    open func configure(options: Options) {
        core?.options = options
        core?.load()
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
    
    open var options: Options? {
        return core?.options
    }
    
    open func getPlugin(name: String) -> Plugin? {
        var plugins: [Plugin] = core?.plugins ?? []
        let containerPlugins: [Plugin] = activeContainer?.plugins ?? []
        
        plugins.append(contentsOf: containerPlugins)
        
        return plugins.first(where: { $0.pluginName == name })
    }

    @discardableResult
    open func on(_ event: Event, callback: @escaping EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }

    private func bindPlaybackEvents() {
        guard let playback = core?.activePlayback else { return }
        
        var listenId = ""
        playbackEventsToListen.forEach { event in
            listenId = listenTo(playback, eventName: event) { [weak self] (info: EventUserInfo) in
                self?.trigger(event, userInfo: info)
            }
            
            playbackEventsListenIds.append(listenId)
        }
        
        listenId = listenTo(playback, eventName: Event.error.rawValue) { [weak self] info in
            self?.trigger(Event.error, userInfo: self?.fillErrorWith(info))
        }
        playbackEventsListenIds.append(listenId)
    }

    open func fillErrorWith(_ userInfo: EventUserInfo) -> EventUserInfo {
        return userInfo
    }
    
    private func unbindPlaybackEvents() {
        for eventId in playbackEventsListenIds {
            stopListening(eventId)
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
    
    open class func register(plugins: [Plugin.Type]) {
        if !hasAlreadyRegisteredPlugins {
            let builtInPlugins: [Plugin.Type] = [
                MediaControl.self,
                PosterPlugin.self,
                SpinnerPlugin.self,
                PlayButton.self,
                TimeIndicator.self,
                FullscreenButton.self,
                Seekbar.self,
                QuickSeekCorePlugin.self,
                QuickSeekMediaControlPlugin.self]

            Loader.shared.register(plugins: builtInPlugins)
            hasAlreadyRegisteredPlugins = true
        }

        Loader.shared.register(plugins: plugins)
    }

    open func destroy() {
        Logger.logDebug("destroying", scope: "Player")
        Logger.logDebug("destroying core", scope: "Player")
        self.core?.destroy()
        self.core = nil
        trigger(.didDestroy)
        stopListening()
        Logger.logDebug("destroyed", scope: "Player")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
