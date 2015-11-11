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
    
    private func eventBindings() -> [PlaybackEvent : EventCallback]{
        return [
            .Ready                  : { [weak self] _ in self?.setReady() },
            .Buffering              : { [weak self] _ in self?.trigger(.Buffering)},
            .BufferFull             : { [weak self] _ in self?.trigger(.BufferFull)},
            .SettingsUpdated        : { [weak self] _ in self?.settingsUpdated()},
            .HighDefinitionUpdated  : { [weak self] _ in self?.trigger(.HighDefinitionUpdated)},
            .StateChanged           : { [weak self] _ in self?.trigger(.PlaybackStateChanged)},
            .MediaControlDisabled   : { [weak self] _ in self?.trigger(.MediaControlDisabled)},
            .MediaControlEnabled    : { [weak self] _ in self?.trigger(.MediaControlEnabled)},
            .Ended                  : { [weak self] _ in self?.trigger(.Ended)},
            .Play                   : { [weak self] _ in self?.trigger(.Play)},
            .Pause                  : { [weak self] _ in self?.trigger(.Pause)},
            .Progress               : progressBindingCallback(),
            .TimeUpdated            : timeUpdatedBindingCallback()
        ]
    }
    
    private func progressBindingCallback() -> EventCallback {
        return { [weak self] userInfo in
            let start = userInfo?["start_position"] as! Float
            let end = userInfo?["end_position"] as! Float
            let duration = userInfo?["duration"] as! NSTimeInterval
            
            self?.progressUpdated(start, endPosition: end, duration: duration)
        }
    }
    
    private func timeUpdatedBindingCallback() -> EventCallback {
        return { [weak self] userInfo in
            let position = userInfo?["position"] as! Float
            let duration = userInfo?["duration"] as! NSTimeInterval
            
            self?.timeUpdated(position, duration: duration)
        }
    }
    
    private func settingsUpdated() {
        settings = playback.settings
        self.trigger(.SettingsUpdated)
    }
    
    private func progressUpdated(startPosition: Float, endPosition: Float, duration: NSTimeInterval) {
        let userInfo: EventUserInfo = ["start_position" : startPosition,
                                         "end_position" : endPosition,
                                             "duration" : duration]
        
        trigger(ContainerEvent.Progress.rawValue, userInfo: userInfo)
    }
    
    private func timeUpdated(position: Float, duration: NSTimeInterval) {
        let userInfo: EventUserInfo = ["position": position, "duration": duration]
        trigger(ContainerEvent.TimeUpdated.rawValue, userInfo: userInfo)
    }
    
    private func setReady() {
        ready = true
        trigger(ContainerEvent.Ready)
    }
    
    private func trigger(event: ContainerEvent) {
        trigger(event.rawValue)
    }
}