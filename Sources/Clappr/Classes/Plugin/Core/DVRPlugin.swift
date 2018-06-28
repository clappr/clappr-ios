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
        triggerDvrEvent()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
    }
    
    private func bindPlaybackEvents() {
        guard let playback = playback else { return }
        listenToOnce(playback, eventName: Event.bufferUpdate.rawValue) { [weak self] (_: EventUserInfo) in self?.triggerDvrEvent() }
    }
    
    private func bindContainerEvents() {
        guard let container = core?.activeContainer else { return }
        listenTo(container, eventName: InternalEvent.didChangePlayback.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
    }
    
    func triggerDvrEvent() {
        guard let duration = duration else { return }
        let userInfo = ["dvrEnabled": dvrEnabled,
                        "duration": duration] as [String : Any]
        playback?.trigger(InternalEvent.detectDVR.rawValue, userInfo: userInfo)
    }
}

//MARK: DVR
extension DVRPlugin {
    var minDvrSize: Double {
        return 60
    }
    
    var duration: Double? {
        guard let currentTime = playback?.player?.currentTime() else { return nil }
        return CMTimeGetSeconds(currentTime)
    }
    
    private var dvrEnabled: Bool {
        guard let duration = duration else { return false }
        return playback?.playbackType == .live && duration >= minDvrSize
    }
}
