open class Player: BaseObject {

    @objc open var playbackEventsToListen: [String] = []
    private var playbackEventsListenIds: [String] = []
    @objc private(set) var core: Core?

    static var hasAlreadyRegisteredPlugins = false
    static var hasAlreadyRegisteredPlaybacks = false

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

    @objc open var state: PlaybackState {
        return activePlayback?.state ?? .none
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

    public init(options: Options = [:]) {
        super.init()
        Player.register(playbacks: [])
        Player.register(plugins: [])
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
             Event.didSelectSubtitle.rawValue, Event.didSelectAudio.rawValue])

        setCore(with: options)

        bindPlaybackEvents()
    }
    
    private func setCore(with options: Options) {
        core?.stopListening()
        core = CoreFactory.create(with: options)
        bindCoreEvents()
    }

    private func bindCoreEvents() {
        core?.on(Event.willChangeActivePlayback.rawValue) { [weak self] _ in self?.unbindPlaybackEvents() }
        core?.on(Event.didChangeActivePlayback.rawValue) { [weak self] _ in self?.bindPlaybackEvents() }
        core?.on(InternalEvent.userRequestEnterInFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.trigger(Event.requestFullscreen.rawValue, userInfo: info) }
        core?.on(InternalEvent.userRequestExitFullscreen.rawValue) { [weak self] (info: EventUserInfo) in self?.trigger(Event.exitFullscreen.rawValue, userInfo: info) }
    }
    
    @objc open func presentFullscreenIn(_ controller: UIViewController) {
        guard let coreView = core?.view else { return }
        controller.view.addSubviewMatchingConstraints(coreView)
    }
    
    @objc open func fitParentView() {
        guard let coreView = core?.view else { return }
        core?.parentView?.addSubviewMatchingConstraints(coreView)
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

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Player")
        Logger.logDebug("destroying core", scope: "Player")
        self.core?.destroy()
        self.core = nil
        stopListening()
        Logger.logDebug("destroyed", scope: "Player")
    }
}
