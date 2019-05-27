open class ActiveCorePlugin: CorePlugin {

    @objc public required init(context: UIObject) {
        super.init(context: context)
        bindAllEvents()
    }

    func bindAllEvents() {
        stopListening()
        bindEvents()
        guard let core = core else { return }
        listenTo(core, eventName: Event.didChangeActiveContainer.rawValue) { [weak self] _ in
            self?.bindAllEvents()
            self?.onDidChangeActiveContainer()
        }
        guard let container = core.activeContainer else { return }
        listenTo(container, event: .didChangePlayback) { [weak self] _ in
            self?.bindAllEvents()
            self?.onDidChangePlayback()
        }
    }

    open func bindEvents() { }

    open func onDidChangePlayback() { }

    open func onDidChangeActiveContainer() { }

}
