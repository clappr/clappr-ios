import AVFoundation

open class DVRPlugin: UICorePlugin {
    
    open override var pluginName: String {
        return "dvr"
    }
    
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        super.init()
    }
    
    @objc public required init(context: UIBaseObject) {
        super.init(context: context)
        bindEvents()
    }
    
    private var playback: AVFoundationPlayback? {
        return core?.activePlayback as? AVFoundationPlayback
    }
}

//MARK: Events Binding
extension DVRPlugin {
    private func bindEvents() {
        stopListening()
        
        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] _ in
            self?.bindEvents()
            self?.triggerDvrEvent()
        }
    }
    
    private func bindPlaybackEvents() {
        guard let playback = playback else { return }
        listenToOnce(playback, eventName: Event.bufferUpdate.rawValue) { [weak self] _ in self?.triggerDvrEvent() }
        listenTo(playback, eventName: Event.didSeek.rawValue) { [weak self] (info: EventUserInfo) in self?.triggerDvrUsageEvent(info: info) }
    }
    
    private func bindContainerEvents() {
        guard let container = core?.activeContainer else { return }
        listenTo(container, eventName: InternalEvent.didChangePlayback.rawValue) { [weak self] _ in
            self?.bindEvents()
            self?.triggerDvrEvent()
        }
    }

    func triggerDvrEvent() {
        guard let duration = duration else { return }
        let userInfo = ["enabled": supportDVR,
                        "duration": duration] as [String : Any]
        playback?.trigger(InternalEvent.supportDVR.rawValue, userInfo: userInfo)
    }

    func triggerDvrUsageEvent(info: EventUserInfo) {
        guard supportDVR else { return }
        guard let position = position else { return }
        guard let currentTime = duration else { return }
        let dvrUsage = position < currentTime
        let userInfo = ["enabled": dvrUsage] as [String : Any]
        playback?.trigger(InternalEvent.usingDVR.rawValue, userInfo: userInfo)
    }
}

//MARK: DVR
extension DVRPlugin {
    var minDvrSize: Double {
        return 60
    }
    
    var position: Double? {
        guard let currentTime = playback?.player?.currentTime() else { return nil }
        return CMTimeGetSeconds(currentTime)
    }
    
    var duration: Double? {
        guard let range = playback?.player?.currentItem?.seekableTimeRanges.compactMap({ $0.timeRangeValue }).first else {
            return nil
        }
        return CMTimeGetSeconds(range.duration)
    }
    
    private var supportDVR: Bool {
        guard let duration = duration else { return false }
        return playback?.playbackType == .live && duration >= minDvrSize
    }
}
