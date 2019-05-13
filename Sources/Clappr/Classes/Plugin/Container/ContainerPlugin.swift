open class ContainerPlugin: BaseObject, Plugin {
    @objc open weak var container: Container?
    open class var type: PluginType { return .container }

    @objc open class var name: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Container Plugins should always declare a name. \(self) does not.", userInfo: nil).raise()
        return ""
    }
    
    @objc public required init(context: UIObject) {
        super.init()
        if let container = context as? Container {
            self.container = container
        } else {
            NSException(name: NSExceptionName(rawValue: "WrongContextType"), reason: "Container Plugins should always be initialized with a Container context", userInfo: nil).raise()
        }
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

    open func destroy() {
        Logger.logDebug("destroying", scope: "ContainerPlugin")
        Logger.logDebug("destroying listeners", scope: "ContainerPlugin")
        stopListening()
        Logger.logDebug("destroyed", scope: "ContainerPlugin")
    }
}
