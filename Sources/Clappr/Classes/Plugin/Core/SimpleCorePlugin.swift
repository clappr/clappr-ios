open class SimpleCorePlugin: CorePlugin {
    open var activeContainer: Container? {
        return core?.activeContainer
    }

    open var activePlayback: Playback? {
        return core?.activePlayback
    }

    @objc public required init(context: UIObject) {
        super.init(context: context)

        bindAllEvents()
    }

    func bindAllEvents() {
        stopListening()

        bindEvents()
        bindCoreEvents()
        bindContainerEvents()
    }

    open func bindEvents() {
        let exceptionName = NSExceptionName(rawValue: "MissingBindEvents")
        let exceptionReason = "SimpleCorePlugins should always override bindEvents with its own binds: \(pluginName) does not implement."
        NSException(name: exceptionName, reason: exceptionReason, userInfo: nil).raise()
    }

    private func bindCoreEvents() {
        guard let core = core else { return }

        listenTo(core, event: .didChangeActiveContainer) { [weak self] _ in
            self?.bindAllEvents()
            self?.onDidChangeActiveContainer()
        }
    }

    private func bindContainerEvents() {
        guard let container = activeContainer else { return }

        listenTo(container, event: .didChangePlayback) { [weak self] _ in
            self?.bindAllEvents()
            self?.onDidChangePlayback()
        }
    }

    open func onDidChangePlayback() { }
    open func onDidChangeActiveContainer() { }
}
