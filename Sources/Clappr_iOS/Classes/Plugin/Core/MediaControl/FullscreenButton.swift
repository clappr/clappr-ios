open class FullscreenButton: MediaControlPlugin {
    public var fullscreenIcon = UIImage.fromName("fullscreen", for: FullscreenButton.self)
    public var windowedIcon = UIImage.fromName("fullscreen_exit", for: FullscreenButton.self)
    
    public var button: UIButton! {
        didSet {
            button.accessibilityIdentifier = "FullscreenButton"
            
            button.setImage(fullscreenIcon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            
            button.addTarget(self, action: #selector(toggleFullscreenButton), for: .touchUpInside)
            view.isHidden = core?.options[kFullscreenDisabled] as? Bool ?? false
            view.addSubview(button)
        }
    }
    
    open var isOnFullscreen = false {
        didSet {
            let icon = isOnFullscreen ? windowedIcon : fullscreenIcon
            button.setImage(icon, for: .normal)
        }
    }

    open class override var name: String {
        return "FullscreenButton"
    }
    
    override open var panel: MediaControlPanel {
        return .bottom
    }
    
    override open var position: MediaControlPosition {
        return .right
    }
    
    override open func bindEvents() {
        bindCoreEvents()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core,
                 eventName: Event.didEnterFullscreen.rawValue) { [weak self] (_: EventUserInfo) in self?.isOnFullscreen = true }
        listenTo(core,
                 eventName: Event.didExitFullscreen.rawValue) { [weak self] (_: EventUserInfo) in self?.isOnFullscreen = false }
    }
    
    override open func render() {
        setupButton()
    }
    
    private func setupButton() {
        button = UIButton(type: .custom)
        button.bindFrameToSuperviewBounds()
    }
    
    @objc open func toggleFullscreenButton() {
        let event: InternalEvent = isOnFullscreen ? .userRequestExitFullscreen : .userRequestEnterInFullscreen
        core?.trigger(event.rawValue)
    }
}
