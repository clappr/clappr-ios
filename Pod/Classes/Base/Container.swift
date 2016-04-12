import Foundation

public class Container: UIBaseObject {
    public internal(set) var ready = false
    public internal(set) var dvrInUse = false
    public internal(set) var settings: [String : AnyObject] = [:]
    public internal(set) var plugins: [UIContainerPlugin] = []
    public internal(set) var options: Options
    
    public var isPlaying: Bool {
        get {
            return playback.isPlaying()
        }
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

    public init(playback: Playback, options: Options = [:]) {
        self.playback = playback
        self.options = options
        super.init(frame: CGRect.zero)
        bindEventListeners()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(playback: Playback) instead")
    }
    
    public func replacePlayback(type: Playback.Type) {
        playback.removeFromSuperview()
        playback = type.init(options: options)
        renderPlayback()
    }
    
    public override func render() {
        plugins.forEach(renderPlugin)
        renderPlayback()
    }
    
    private func renderPlugin(plugin: UIContainerPlugin) {
        addSubview(plugin)
        plugin.render()
    }
    
    private func renderPlayback() {
        addSubviewMatchingConstraints(playback)
        playback.render()
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
    
    public func seekTo(timeInterval: NSTimeInterval) {
        playback.seekTo(timeInterval)
    }
    
    public func addPlugin(plugin: UIContainerPlugin) {
        plugin.container = self
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
            .Play                   : { [weak self] (info: EventUserInfo) in self?.trigger(.Play)},
            .Pause                  : { [weak self] (info: EventUserInfo) in self?.trigger(.Pause)},
            .MediaControlDisabled   : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = false },
            .MediaControlEnabled    : { [weak self] (info: EventUserInfo) in self?.mediaControlEnabled = true },
            .SettingsUpdated        : { [weak self] (info: EventUserInfo) in self?.settingsUpdated()},
            .Ready                  : { [weak self] (info: EventUserInfo) in self?.setReady() },
            .DVRStateChanged        : { [weak self] (info: EventUserInfo) in self?.setDvrInUse(info) },
            .Progress               : { [weak self] (info: EventUserInfo) in self?.forward(.Progress, userInfo:info)},
            .TimeUpdated            : { [weak self] (info: EventUserInfo) in self?.forward(.TimeUpdated, userInfo:info)},
            .LoadedMetadata         : { [weak self] (info: EventUserInfo) in self?.forward(.LoadedMetadata, userInfo:info)},
            .BitRate                : { [weak self] (info: EventUserInfo) in self?.forward(.BitRate, userInfo:info)},
            .Error                  : { [weak self] (info: EventUserInfo) in self?.forward(.Error, userInfo:info)},
        ]
    }
    
    private func settingsUpdated() {
        settings = playback.settings()
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