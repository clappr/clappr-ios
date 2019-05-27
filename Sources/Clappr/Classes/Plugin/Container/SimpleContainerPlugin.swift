open class SimpleContainerPlugin : ContainerPlugin {

    @objc public required init(context: UIObject) {
        super.init(context: context)
        bindAllEvents()
    }

    func bindAllEvents() {
        stopListening()
        bindEvents()
        guard let container = container else { return }
        listenTo(container, event: .didChangePlayback) { [weak self] _ in
            self?.bindAllEvents()
            self?.onDidChangePlayback()
        }
    }

    open func bindEvents() { }

    open func onDidChangePlayback() { }

}
