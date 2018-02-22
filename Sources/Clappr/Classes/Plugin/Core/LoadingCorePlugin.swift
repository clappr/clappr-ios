open class LoadingCorePlugin: UICorePlugin {

    fileprivate var spinningWheel: UIActivityIndicatorView!

    public required init() {
        super.init()
    }

    open override var pluginName: String {
        return "spinner"
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var container: Container? {
        return core?.activeContainer
    }

    public required init(context: UIBaseObject) {
        super.init(context: context)
        spinningWheel = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        addSubview(spinningWheel)
        isUserInteractionEnabled = false
        bindCoreEvents()
        accessibilityIdentifier = "LoadingCorePlugin"
    }

    private func bindCoreEvents() {
        if let core = core {
            listenTo(core, eventName: InternalEvent.didChangeActiveContainer.rawValue) { [weak self] (info: EventUserInfo) in self?.bindEvents(info) }
        }
    }

    private func bindEvents(_: EventUserInfo) {
        stopListening()
        bindPlaybackEvents()
        bindCoreEvents()
    }

    open override func render() {
        setupConstraints()
    }

    fileprivate func setupConstraints() {
        guard let core = core else { return }
        translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: spinningWheel.frame.size.width).isActive = true
        heightAnchor.constraint(equalToConstant: spinningWheel.frame.size.height).isActive = true

        centerXAnchor.constraint(equalTo: core.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: core.centerYAnchor).isActive = true
    }

    private func bindPlaybackEvents() {
        guard let playback = container?.playback else { return }
        listenTo(playback, eventName: Event.playing.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
        listenTo(playback, eventName: Event.stalled.rawValue) { [weak self] (info: EventUserInfo) in self?.startAnimating(info) }
        listenTo(playback, eventName: Event.error.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
        listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
    }

    fileprivate func startAnimating(_: EventUserInfo) {
        spinningWheel.startAnimating()
        Logger.logDebug("started animating spinning wheel", scope: pluginName)
    }

    fileprivate func stopAnimating(_: EventUserInfo) {
        spinningWheel.stopAnimating()
        Logger.logDebug("stoped animating spinning wheel", scope: pluginName)
    }

    open override func destroy() {
        super.destroy()
        Logger.logDebug("destroying", scope: "LoadingCorePlugin")
        Logger.logDebug("destroying ui elements", scope: "LoadingCorePlugin")
        removeFromSuperview()
        Logger.logDebug("destroyed", scope: "LoadingCorePlugin")
    }
}
