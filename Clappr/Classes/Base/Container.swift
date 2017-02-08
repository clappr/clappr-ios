import Foundation

open class Container: UIBaseObject {
    open internal(set) var ready = false
    open internal(set) var plugins: [UIContainerPlugin] = []
    open internal(set) var options: Options

    fileprivate var buffering = false
    fileprivate var loader: Loader

    
    open var isPlaying: Bool {
        return playback?.isPlaying ?? false
    }
    
    open var mediaControlEnabled = false {
        didSet {
            let eventToTrigger: ContainerEvent = mediaControlEnabled ? .mediaControlEnabled : .mediaControlDisabled
            trigger(eventToTrigger)
        }
    }

    open internal(set) var playback: Playback? {
        didSet {
            stopListening()
            bindEventListeners()
        }
    }

    public init(loader: Loader = Loader(), options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.options = options
        self.loader = loader
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        loadPlugins()

        if let source = options[kSourceUrl] as? String {
            load(source, mimeType: options[kMimeType] as? String)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(playback: Playback) instead")
    }
    
    open func load(_ source: String, mimeType: String? = nil) {
        var playbackOptions = options
        playbackOptions[kSourceUrl] = source as AnyObject?
        playbackOptions[kMimeType] = mimeType as AnyObject?? ?? nil
        
        let playbackFactory = PlaybackFactory(loader: loader, options: playbackOptions)
        
        playback?.removeFromSuperview()
        playback = playbackFactory.createPlayback()
        renderPlayback()
        trigger(ContainerEvent.sourceChanged)
    }
    
    open override func render() {
        plugins.forEach(renderPlugin)
        renderPlayback()
    }

    fileprivate func renderPlayback() {
        guard let playback = playback else {
            return
        }

        addSubviewMatchingConstraints(playback)
        playback.render()
        sendSubview(toBack: playback)
    }
    
    fileprivate func renderPlugin(_ plugin: UIContainerPlugin) {
        addSubview(plugin)
        plugin.render()
    }
    
    open func destroy() {
        stopListening()
        playback?.destroy()
        
        removeFromSuperview()
    }

    open func play() {
        playback?.play()
    }
    
    open func pause() {
        playback?.pause()
    }
    
    open func stop() {
        playback?.stop()
        trigger(ContainerEvent.stop)
    }
    
    open func seek(timeInterval: TimeInterval) {
        playback?.seek(timeInterval)
    }

    private func loadPlugins() {
        for type in loader.containerPlugins {
            addPlugin(type.init(context: self) as! UIContainerPlugin)
        }
    }
    
    open func addPlugin(_ plugin: UIContainerPlugin) {
        plugins.append(plugin)
    }
    
    open func hasPlugin(_ pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKind(of: pluginClass)}).count > 0
    }

    fileprivate func bindEventListeners() {
        guard let playback = playback else {
            return
        }

        for (event, callback) in eventBindings() {
            listenTo(playback, eventName: event.rawValue, callback: callback)
        }
    }

    fileprivate func eventBindings() -> [Event : EventCallback] {
        return [
            .stalled              : { [weak self] (info: EventUserInfo) in self?.onStall()} as EventCallback,
            .didComplete          : { [weak self] (info: EventUserInfo) in self?.trigger(.ended)} as EventCallback,
            .playing              : { [weak self] (info: EventUserInfo) in self?.onPlay()} as EventCallback,
            .didPause             : { [weak self] (info: EventUserInfo) in self?.trigger(.pause)} as EventCallback,
            .disableMediaControl  : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = false } as EventCallback,
            .enableMediaControl   : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = true } as EventCallback,
            .ready                : { [weak self] (info: EventUserInfo) in self?.setReady() } as EventCallback,
            .bufferUpdate         : { [weak self] (info: EventUserInfo) in self?.forward(.progress, userInfo:info)} as EventCallback,
            .positionUpdate       : { [weak self] (info: EventUserInfo) in self?.forward(.timeUpdated, userInfo:info)} as EventCallback,
            .didUpdateSubtitleSource : { [weak self] (info: EventUserInfo) in self?.forward(.subtitleSourcesUpdated, userInfo:info)} as EventCallback,
            .didUpdateAudioSource : { [weak self] (info: EventUserInfo) in self?.forward(.audioSourcesUpdated, userInfo:info)} as EventCallback,
            .error                : { [weak self] (info: EventUserInfo) in self?.forward(.error, userInfo:info)} as EventCallback,
        ]
    }

    fileprivate func onStall() {
        trigger(.buffering)
        buffering = true
    }

    fileprivate func onPlay() {
        if buffering {
            buffering = false
            trigger(.bufferFull)
        }

        options[kStartAt] = 0.0
        trigger(.play)
    }

    fileprivate func setReady() {
        ready = true
        trigger(ContainerEvent.ready)
    }

    fileprivate func trigger(_ event: ContainerEvent) {
        trigger(event.rawValue)
    }
    
    fileprivate func forward(_ event: ContainerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}
