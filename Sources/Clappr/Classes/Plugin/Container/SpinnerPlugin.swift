open class SpinnerPlugin: UIContainerPlugin {

    fileprivate var spinningWheel: UIActivityIndicatorView!

    @objc var isAnimating: Bool {
        return spinningWheel.isAnimating
    }

    open class override var name: String {
        return "spinner"
    }

    public required init(context: UIObject) {
        super.init(context: context)
        spinningWheel = UIActivityIndicatorView(style: .whiteLarge)
        view.addSubview(spinningWheel)
        view.isUserInteractionEnabled = false
        view.accessibilityIdentifier = "SpinnerPlugin"
    }

    override open func bindEvents() {
        bindPlaybackEvents()
    }

    open override func render() {
        addCenteringConstraints()
    }

    fileprivate func addCenteringConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false

        let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: spinningWheel.frame.width)
        view.addConstraint(widthConstraint)

        let heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: spinningWheel.frame.height)
        view.addConstraint(heightConstraint)

        let xCenterConstraint = NSLayoutConstraint(item: view, attribute: .centerX,
                                                   relatedBy: .equal, toItem: container?.view, attribute: .centerX, multiplier: 1, constant: 0)
        container?.view.addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: view, attribute: .centerY,
                                                   relatedBy: .equal, toItem: container?.view, attribute: .centerY, multiplier: 1, constant: 0)
        container?.view.addConstraint(yCenterConstraint)
    }

    private func bindPlaybackEvents() {
        guard let playback = playback else { return }
        listenTo(playback, eventName: Event.playing.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
        listenTo(playback, eventName: Event.stalling.rawValue) { [weak self] (info: EventUserInfo) in self?.startAnimating(info) }
        listenTo(playback, eventName: Event.error.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }
        listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] (info: EventUserInfo) in self?.stopAnimating(info) }

    }

    fileprivate func startAnimating(_: EventUserInfo) {
        view.isHidden = false
        spinningWheel.startAnimating()
        Logger.logDebug("started animating spinning wheel", scope: pluginName)
    }

    fileprivate func stopAnimating(_: EventUserInfo) {
        view.isHidden = true
        spinningWheel.stopAnimating()
        Logger.logDebug("stoped animating spinning wheel", scope: pluginName)
    }

    open override func destroy() {
        super.destroy()
        Logger.logDebug("destroying", scope: "SpinnerPlugin")
        Logger.logDebug("destroying ui elements", scope: "SpinnerPlugin")
        view.removeFromSuperview()
        Logger.logDebug("destroyed", scope: "SpinnerPlugin")
    }
}
