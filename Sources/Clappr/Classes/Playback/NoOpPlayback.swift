open class NoOpPlayback: Playback {
    fileprivate var errorLabel = UILabel(frame: CGRect.zero)

    open class override var name: String {
        return "NoOp"
    }

    public required init(options: Options) {
        super.init(options: options)
        setupLabel()
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init(context _: UIObject) {
        fatalError("init(context:) has not been implemented")
    }

    open override class func canPlay(_: Options) -> Bool {
        return true
    }

    open override func render() {
        view.addSubviewMatchingConstraints(errorLabel)
    }

    fileprivate func setupLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = labelText()
        errorLabel.textAlignment = .center
        errorLabel.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        errorLabel.textColor = UIColor.white
    }

    fileprivate func labelText() -> String {
        if let text = options[kPlaybackNotSupportedMessage] as? String {
            return text
        }
        return "Could not play video"
    }

    override open func destroy() {
        super.destroy()
        Logger.logDebug("destroyed", scope: "NOOpPlayback")
    }
}
