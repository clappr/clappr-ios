open class FullscreenButton: MediaControlPlugin {
    private var fullscreenIcon = UIImage.fromName("fullscreen", for: FullscreenButton.self)
    private var windowedIcon = UIImage.fromName("fullscreen_exit", for: FullscreenButton.self)
    
    var button: UIButton! {
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
    
    private var isOnFullscreen = false {
        didSet {
            let icon = isOnFullscreen ? windowedIcon : fullscreenIcon
            button.setImage(icon, for: .normal)
        }
    }

    override open var pluginName: String {
        return "FullscreenButton"
    }
    
    override open var panel: MediaControlPanel {
        return .bottom
    }
    
    override open var position: MediaControlPosition {
        return .right
    }
    
    required public init(context: UIObject) {
        super.init(context: context)
        bindEvents()
    }
    
    required public init() {
        super.init()
    }
    
    private func bindEvents() {
        stopListening()
        bindCoreEvents()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core,
                 eventName: InternalEvent.didEnterFullscreen.rawValue) { [weak self] (_: EventUserInfo) in self?.isOnFullscreen = true }
        listenTo(core,
                 eventName: InternalEvent.didExitFullscreen.rawValue) { [weak self] (_: EventUserInfo) in self?.isOnFullscreen = false }
    }
    
    override open func render() {
        setupButton()
    }
    
    private func setupButton() {
        button = UIButton(type: .custom)
        button.bindFrameToSuperviewBounds()
    }
    
    @objc open func toggleFullscreenButton() {
        if isOnFullscreen {
            core?.trigger(InternalEvent.userRequestExitFullscreen.rawValue)
        } else {
            core?.trigger(InternalEvent.userRequestEnterInFullscreen.rawValue)
        }
    }
}
