public class Container: UIBaseObject {
    public internal(set) var ready = false
    public internal(set) var settings: [String : AnyObject] = [:]
    
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
    }
    
    public func seekTo(timeInterval: NSTimeInterval) {
        playback.seekTo(timeInterval)
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
            .MediaControlDisabled   : { [weak self] _ in self?.trigger(.MediaControlDisabled)},
            .MediaControlEnabled    : { [weak self] _ in self?.trigger(.MediaControlEnabled)},
            .Ended                  : { [weak self] _ in self?.trigger(.Ended)},
            .Play                   : { [weak self] _ in self?.trigger(.Play)},
            .Pause                  : { [weak self] _ in self?.trigger(.Pause)},
            .SettingsUpdated        : { [weak self] _ in self?.settingsUpdated()},
            .Ready                  : { [weak self] _ in self?.setReady() },
            .Progress               : { [weak self] info in self?.forward(.Progress, userInfo:info)},
            .TimeUpdated            : { [weak self] info in self?.forward(.TimeUpdated, userInfo:info)}
        ]
    }
    
    private func settingsUpdated() {
        settings = playback.settings
        self.trigger(.SettingsUpdated)
    }
    
    private func setReady() {
        ready = true
        trigger(ContainerEvent.Ready)
    }
    
    private func trigger(event: ContainerEvent) {
        trigger(event.rawValue)
    }
    
    private func forward(event: ContainerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}