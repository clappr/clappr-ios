public class Container: UIBaseObject {
    public internal(set) var ready = false
    
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
        bind(PlaybackEvent.Progress) {[weak self] userInfo in
            let start = userInfo?["start_position"] as! Float
            let end = userInfo?["end_position"] as! Float
            let duration = userInfo?["duration"] as! NSTimeInterval
            
            self?.postProgress(start, endPosition: end, duration: duration)
        }
        
        bind(PlaybackEvent.TimeUpdated) { [weak self] userInfo in
            let position = userInfo?["position"] as! Float
            let duration = userInfo?["duration"] as! NSTimeInterval
            
            self?.timeUpdated(position, duration: duration)
        }
        
        bind(PlaybackEvent.Ready) { [weak self] _ in
            self?.setReady()
        }
    }
    
    private func bind(event: PlaybackEvent, callback: EventCallback) {
        playback.listenTo(self, eventName: event.rawValue, callback: callback)
    }
    
    private func postProgress(startPosition: Float, endPosition: Float, duration: NSTimeInterval) {
        let userInfo: EventUserInfo = ["start_position": startPosition,
                                         "end_position": endPosition,
                                             "duration": duration]
        
        trigger(ContainerEvent.Progress.rawValue, userInfo: userInfo)
    }
    
    private func timeUpdated(position: Float, duration: NSTimeInterval) {
        let userInfo: EventUserInfo = ["position": position, "duration": duration]
        trigger(ContainerEvent.TimeUpdated.rawValue, userInfo: userInfo)
    }
    
    private func setReady() {
        ready = true
        trigger(ContainerEvent.Ready.rawValue)
    }
}