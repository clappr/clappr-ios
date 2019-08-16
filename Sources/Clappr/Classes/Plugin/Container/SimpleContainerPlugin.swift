open class SimpleContainerPlugin: ContainerPlugin {
    open var activePlayback: Playback? {
        return container?.playback
    }

    @objc public required init(context: UIObject) {
        super.init(context: context)
        
        bindAllEvents()
    }

    func bindAllEvents() {
        stopListening()
        
        bindEvents()
        bindContainerEvents()
    }

    open func bindEvents() {
        let exceptionName = NSExceptionName(rawValue: "MissingBindEvents")
        let exceptionReason = "SimpleContainerPlugins should always override bindEvents with its own binds: \(pluginName) does not implement."

        NSException(name: exceptionName, reason: exceptionReason, userInfo: nil).raise()
    }

    private func bindContainerEvents() {
        guard let container = container else { return }

        listenTo(container, event: .didChangePlayback) { [weak self] _ in
            self?.bindAllEvents()
            self?.onDidChangePlayback()
        }
    }

    open func onDidChangePlayback() { }

}
