open class DVRPlugin: UIContainerPlugin {
    
    open override var pluginName: String {
        return "dvr"
    }
    
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        fatalError("init() has not been implemented")
    }
    
    @objc public required init(context: UIBaseObject) {
        super.init(context: context)
    }
    
    private func bindPlaybackEvents() {
        guard let playback = container?.playback else { return }
        listenTo(playback, eventName: InternalEvent.didLoadSource.rawValue) { [weak self] (info: EventUserInfo) in self?.didLoadSource(info) }
    }
    
    private func didLoadSource(_: EventUserInfo) {
        
    }
    
    func shouldEnableDVR() -> Bool {
        return true
    }
}
