import Foundation

public class Container: UIBaseObject {
    public internal(set) var ready = false
    public internal(set) var dvrInUse = false
    public internal(set) var settings: [String : AnyObject] = [:]
    public internal(set) var plugins: [UIContainerPlugin] = []
    public internal(set) var options: Options
    
    private var loader: Loader
    
    public var isPlaying: Bool {
        return playback.isPlaying
    }
    
    public var mediaControlEnabled = false {
        didSet {
            let eventToTrigger: ContainerEvent = mediaControlEnabled ? .MediaControlEnabled : .MediaControlDisabled
            trigger(eventToTrigger)
        }
    }
    
    public internal(set) var playback: Playback {
        didSet {
            stopListening()
            bindEventListeners()
        }
    }

    public init(playback: Playback, loader: Loader = Loader(), options: Options = [:]) {
        Logger.logDebug("Loading with \(options)", scope: "\(self.dynamicType)")
        self.playback = playback
        self.options = options
        self.loader = loader
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clearColor()
        bindEventListeners()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(playback: Playback) instead")
    }
    
    public func load(source: String, mimeType: String? = nil) {
        var playbackOptions = options
        playbackOptions[kSourceUrl] = source
        playbackOptions[kMimeType] = mimeType ?? nil
        
        let playbackFactory = PlaybackFactory(loader: loader, options: playbackOptions)
        
        playback.removeFromSuperview()
        playback = playbackFactory.createPlayback()
        renderPlayback()
        trigger(ContainerEvent.SourceChanged)
    }
    
    public override func render() {
        plugins.forEach(renderPlugin)
        renderPlayback()
    }
    
    private func renderPlayback() {
        addSubviewMatchingConstraints(playback)
        playback.render()
        sendSubviewToBack(playback)
    }
    
    private func renderPlugin(plugin: UIContainerPlugin) {
        addSubview(plugin)
        plugin.render()
    }
    
    public func destroy() {
        stopListening()
        playback.destroy()
        
        removeFromSuperview()
    }
    
    public func play() {
        playback.play()
    }
    
    public func pause() {
        playback.pause()
    }
    
    public func stop() {
        playback.stop()
        trigger(ContainerEvent.Stop)
    }
    
    public func seek(timeInterval: NSTimeInterval) {
        playback.seek(timeInterval)
    }
    
    public func addPlugin(plugin: UIContainerPlugin) {
        plugins.append(plugin)
    }
    
    public func hasPlugin(pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKindOfClass(pluginClass)}).count > 0
    }
    
    private func bindEventListeners() {
        for (event, callback) in eventBindings() {
            listenTo(playback, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func eventBindings() -> [PlaybackEvent : EventCallback] {
        return [
            .Buffering              : { [weak self] (info: EventUserInfo) in self?.trigger(.Buffering)},
            .BufferFull             : { [weak self] (info: EventUserInfo) in self?.trigger(.BufferFull)},
            .HighDefinitionUpdated  : { [weak self] (info: EventUserInfo) in self?.trigger(.HighDefinitionUpdated)},
            .StateChanged           : { [weak self] (info: EventUserInfo) in self?.trigger(.PlaybackStateChanged)},
            .Ended                  : { [weak self] (info: EventUserInfo) in self?.trigger(.Ended)},
            .Play                   : { [weak self] (info: EventUserInfo) in self?.onPlay()},
            .Pause                  : { [weak self] (info: EventUserInfo) in self?.trigger(.Pause)},
            .MediaControlDisabled   : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = false },
            .MediaControlEnabled    : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = true },
            .SettingsUpdated        : { [weak self] (info: EventUserInfo) in self?.settingsUpdated()},
            .Ready                  : { [weak self] (info: EventUserInfo) in self?.setReady() },
            .DVRStateChanged        : { [weak self] (info: EventUserInfo) in self?.setDvrInUse(info) },
            .Progress               : { [weak self] (info: EventUserInfo) in self?.forward(.Progress, userInfo:info)},
            .TimeUpdated            : { [weak self] (info: EventUserInfo) in self?.forward(.TimeUpdated, userInfo:info)},
            .LoadedMetadata         : { [weak self] (info: EventUserInfo) in self?.forward(.LoadedMetadata, userInfo:info)},
            .SubtitleSourcesUpdated : { [weak self] (info: EventUserInfo) in self?.forward(.SubtitleSourcesUpdated, userInfo:info)},
            .AudioSourcesUpdated    : { [weak self] (info: EventUserInfo) in self?.forward(.AudioSourcesUpdated, userInfo:info)},
            .BitRate                : { [weak self] (info: EventUserInfo) in self?.forward(.BitRate, userInfo:info)},
            .Error                  : { [weak self] (info: EventUserInfo) in self?.forward(.Error, userInfo:info)},
        ]
    }

    private func onPlay() {
        options[kStartAt] = 0
        trigger(.Play)
    }
    
    private func settingsUpdated() {
        settings = playback.settings
        self.trigger(ContainerEvent.SettingsUpdated)
    }
    
    private func setReady() {
        ready = true
        trigger(ContainerEvent.Ready)
    }
    
    private func setDvrInUse(userInfo: EventUserInfo) {
        settingsUpdated()
        
        if let playbackDvrInUse = userInfo!["dvr_in_use"] as? Bool {
            dvrInUse = playbackDvrInUse
        }
        
        forward(ContainerEvent.PlaybackDVRStateChanged, userInfo: userInfo)
    }
    
    private func trigger(event: ContainerEvent) {
        trigger(event.rawValue)
    }
    
    private func forward(event: ContainerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}