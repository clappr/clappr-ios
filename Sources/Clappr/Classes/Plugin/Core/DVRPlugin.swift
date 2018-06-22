import AVFoundation

open class DVRPlugin: UICorePlugin {
    
    open override var pluginName: String {
        return "dvr"
    }
    
    var minDvrSize: Double {
        return 100
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
}


//MARK: Events Binding
extension DVRPlugin {
    fileprivate func bindEvents() {
        stopListening()
        
        bindPlaybackEvents()
        bindCoreEvents()
        triggerDvrEvent()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
    }
    
    private func bindPlaybackEvents() {
        guard let playback = core?.activePlayback else { return }
        listenToOnce(playback, eventName: Event.bufferUpdate.rawValue) { [weak self] (_: EventUserInfo) in self?.triggerDvrEvent() }
    }
    
    private var dvrEnabled: Bool {
        guard let playback = core?.activePlayback as? AVFoundationPlayback else { return false }
        guard let player = playback.player else { return false }
        return playback.playbackType == .live && CMTimeGetSeconds(player.currentTime()) >= minDvrSize
    }
    
    func triggerDvrEvent() {
        guard let playback = core?.activePlayback else { return }
        playback.trigger(InternalEvent.detectDVR.rawValue, userInfo: ["enabled": dvrEnabled])
    }
}
