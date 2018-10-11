open class FullscreenButton: MediaControlPlugin {
    private var icon = UIImage.fromName("fullscreen", for: FullscreenButton.self)
    
    var button: UIButton! {
        didSet {
            button.accessibilityIdentifier = "FullscreenButton"
            
            button.setImage(icon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentVerticalAlignment = .fill
            button.contentHorizontalAlignment = .fill
            
            button.addTarget(self, action: #selector(toggleFullscreenButton), for: .touchUpInside)
            view.isHidden = core?.options[kFullscreenDisabled] as? Bool ?? false
            view.addSubview(button)
        }
    }
    
    private var isOnFullscreen = false

    override open var pluginName: String {
        return "FullscreenButton"
    }
    
    override open var panel: MediaControlPanel {
        return .bottom
    }
    
    override open var position: MediaControlPosition {
        return .right
    }
    
    required public init(context: UIBaseObject) {
        super.init(context: context)
        bindEvents()
    }
    
    required public init() {
        super.init()
    }
    
    required public init?(coder argument: NSCoder) {
        super.init(coder: argument)
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
    
    @objc func toggleFullscreenButton() {
        if isOnFullscreen {
            core?.trigger(InternalEvent.userRequestExitFullscreen.rawValue)
        } else {
            core?.trigger(InternalEvent.userRequestEnterInFullscreen.rawValue)
        }
    }
}
