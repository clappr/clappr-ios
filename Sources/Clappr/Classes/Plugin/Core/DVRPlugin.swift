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
        listenTo(core, eventName: InternalEvent.didChangeActivePlayback.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
    }
    
    private func bindPlaybackEvents() {
        guard let playback = self.core?.activeContainer?.playback else { return }
        listenToOnce(playback, eventName: Event.bufferUpdate.rawValue) { [weak self] (_: EventUserInfo) in self?.triggerDvrEvent() }
    }
    
    var dvrEnabled: Bool {
        guard let playback = self.core?.activeContainer?.playback as? AVFoundationPlayback else { return false }
        return playback.playbackType == .live && playback.position > 100
    }
    
    func triggerDvrEvent() {
        core?.trigger("DetectDVR", userInfo: ["enabled": dvrEnabled])
    }
}
