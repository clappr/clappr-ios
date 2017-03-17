import Foundation

open class Container: UIBaseObject {
    open internal(set) var ready = false
    open internal(set) var dvrInUse = false
    open internal(set) var settings: [String : AnyObject] = [:]
    open internal(set) var plugins: [UIContainerPlugin] = []
    open internal(set) var options: Options
    
    fileprivate var loader: Loader
    
    open var isPlaying: Bool {
        return playback.isPlaying
    }
    
    open var mediaControlEnabled = false {
        didSet {
            let eventToTrigger: ContainerEvent = mediaControlEnabled ? .mediaControlEnabled : .mediaControlDisabled
            trigger(eventToTrigger)
        }
    }
    
    open internal(set) var playback: Playback {
        didSet {
            stopListening()
            bindEventListeners()
        }
    }

    public init(playback: Playback, loader: Loader = Loader(), options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.playback = playback
        self.options = options
        self.loader = loader
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
        bindEventListeners()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(playback: Playback) instead")
    }
    
    open func load(_ source: String, mimeType: String? = nil) {
        var playbackOptions = options
        playbackOptions[kSourceUrl] = source as AnyObject?
        playbackOptions[kMimeType] = mimeType as AnyObject?? ?? nil
        
        let playbackFactory = PlaybackFactory(loader: loader, options: playbackOptions)
        
        playback.removeFromSuperview()
        playback = playbackFactory.createPlayback()
        renderPlayback()
        trigger(ContainerEvent.sourceChanged)
    }
    
    open override func render() {
        plugins.forEach(renderPlugin)
        renderPlayback()
    }
    
    fileprivate func renderPlayback() {
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
        playback.destroy()
        
        removeFromSuperview()
    }
    
    open func play() {
        playback.play()
    }
    
    open func pause() {
        playback.pause()
    }
    
    open func stop() {
        playback.stop()
        trigger(ContainerEvent.stop)
    }
    
    open func seek(_ timeInterval: TimeInterval) {
        playback.seek(timeInterval)
    }
    
    open func addPlugin(_ plugin: UIContainerPlugin) {
        plugins.append(plugin)
    }
    
    open func hasPlugin(_ pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKind(of: pluginClass)}).count > 0
    }
    
    fileprivate func bindEventListeners() {
        for (event, callback) in eventBindings() {
            _ = listenTo(playback, eventName: event.rawValue, callback: callback)
        }
    }
    
    fileprivate func eventBindings() -> [PlaybackEvent : EventCallback] {
        return [
            .buffering                : { [weak self] (info: EventUserInfo) in self?.trigger(.buffering) } as EventCallback,
            .bufferFull               : { [weak self] (info: EventUserInfo) in self?.trigger(.bufferFull) } as EventCallback,
            .highDefinitionUpdated    : { [weak self] (info: EventUserInfo) in self?.trigger(.highDefinitionUpdated) } as EventCallback,
            .stateChanged             : { [weak self] (info: EventUserInfo) in self?.trigger(.playbackStateChanged) } as EventCallback,
            .ended                    : { [weak self] (info: EventUserInfo) in self?.trigger(.ended) } as EventCallback,
            .play                     : { [weak self] (info: EventUserInfo) in self?.onPlay() } as EventCallback,
            .pause                    : { [weak self] (info: EventUserInfo) in self?.trigger(.pause) } as EventCallback,
            .mediaControlDisabled     : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = false } as EventCallback,
            .mediaControlEnabled      : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = true } as EventCallback,
            .settingsUpdated          : { [weak self] (info: EventUserInfo) in self?.settingsUpdated() } as EventCallback,
            .ready                    : { [weak self] (info: EventUserInfo) in self?.setReady() } as EventCallback,
            .dvrStateChanged          : { [weak self] (info: EventUserInfo) in self?.setDvrInUse(info) } as EventCallback,
            .progress                 : { [weak self] (info: EventUserInfo) in self?.forward(.progress, userInfo:info) } as EventCallback,
            .timeUpdated              : { [weak self] (info: EventUserInfo) in self?.forward(.timeUpdated, userInfo:info) } as EventCallback,
            .loadedMetadata           : { [weak self] (info: EventUserInfo) in self?.forward(.loadedMetadata, userInfo:info) } as EventCallback,
            .subtitleSourcesUpdated   : { [weak self] (info: EventUserInfo) in self?.forward(.subtitleSourcesUpdated, userInfo:info) } as EventCallback,
            .audioSourcesUpdated      : { [weak self] (info: EventUserInfo) in self?.forward(.audioSourcesUpdated, userInfo:info) } as EventCallback,
            .bitRate                  : { [weak self] (info: EventUserInfo) in self?.forward(.bitRate, userInfo:info) } as EventCallback,
            .error                    : { [weak self] (info: EventUserInfo) in self?.forward(.error, userInfo:info) } as EventCallback,
        ]
    }

    fileprivate func onPlay() {
        options[kStartAt] = 0.0 as AnyObject?
        trigger(ContainerEvent.play)
    }
    
    fileprivate func settingsUpdated() {
        settings = playback.settings
        self.trigger(ContainerEvent.settingsUpdated)
    }
    
    fileprivate func setReady() {
        ready = true
        trigger(ContainerEvent.ready)
    }
    
    fileprivate func setDvrInUse(_ userInfo: EventUserInfo) {
        settingsUpdated()
        
        if let playbackDvrInUse = userInfo!["dvr_in_use"] as? Bool {
            dvrInUse = playbackDvrInUse
        }
        
        forward(ContainerEvent.playbackDVRStateChanged, userInfo: userInfo)
    }
    
    fileprivate func trigger(_ event: ContainerEvent) {
        trigger(event.rawValue)
    }
    
    fileprivate func forward(_ event: ContainerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}
