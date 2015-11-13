import Foundation

public class Container: UIBaseObject {
    public internal(set) var ready = false
    public internal(set) var dvrInUse = false
    public internal(set) var settings: [String : AnyObject] = [:]
    public internal(set) var plugins: [UIContainerPlugin] = []
    
    public var isPlaying: Bool {
        get {
            return playback.isPlaying
        }
    }
    
    public internal(set) var mediaControlEnabled = false {
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

    public init (playback: Playback) {
        self.playback = playback
        super.init(frame: CGRect.zero)
        self.addSubview(playback)
        bindEventListeners()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(playback: Playback) instead")
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
        plugins.append(plugin)
    }
    
    public func hasPlugin(pluginClass: AnyClass) -> Bool {
        return plugins.filter({$0.isKindOfClass(pluginClass)}).count > 0
    }
    
    private func bindEventListeners() {
        for (event, callback) in eventBindings() {
            playback.listenTo(self, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func eventBindings() -> [PlaybackEvent : EventCallback] {
        return [
            .Buffering              : { [weak self] _ in self?.trigger(.Buffering)},
            .BufferFull             : { [weak self] _ in self?.trigger(.BufferFull)},
            .HighDefinitionUpdated  : { [weak self] _ in self?.trigger(.HighDefinitionUpdated)},
            .StateChanged           : { [weak self] _ in self?.trigger(.PlaybackStateChanged)},
            .Ended                  : { [weak self] _ in self?.trigger(.Ended)},
            .Play                   : { [weak self] _ in self?.trigger(.Play)},
            .Pause                  : { [weak self] _ in self?.trigger(.Pause)},
            .MediaControlDisabled   : { [weak self] _ in self?.mediaControlEnabled = false },
            .MediaControlEnabled    : { [weak self] _ in self?.mediaControlEnabled = true },
            .SettingsUpdated        : { [weak self] _ in self?.settingsUpdated()},
            .Ready                  : { [weak self] _ in self?.setReady() },
            .DVRStateChanged        : { [weak self] info in self?.setDvrInUse(info) },
            .Progress               : { [weak self] info in self?.forward(.Progress, userInfo:info)},
            .TimeUpdated            : { [weak self] info in self?.forward(.TimeUpdated, userInfo:info)},
            .LoadedMetadata         : { [weak self] info in self?.forward(.LoadedMetadata, userInfo:info)},
            .BitRate                : { [weak self] info in self?.forward(.BitRate, userInfo:info)},
            .Error                  : { [weak self] info in self?.forward(.Error, userInfo:info)},
        ]
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