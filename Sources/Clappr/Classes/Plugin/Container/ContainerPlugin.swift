open class ContainerPlugin: BaseObject, Plugin {
    @objc open weak var container: Container?
    open class var type: PluginType { return .container }

    @objc open class var name: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Container Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }

    @objc open var pluginName: String {
        guard let selfType = theType(of: self) else { return "" }
        return selfType.name
    }

    public required override init() {
        super.init()
    }
    
    @objc public required init(context: UIObject) {
        super.init()
        if let container = context as? Container {
            self.container = container
        } else {
            NSException(name: NSExceptionName(rawValue: "WrongContextType"), reason: "Container Plugins should always be initialized with a Container context", userInfo: nil).raise()
        }
    }
    
    open func destroy() {
        Logger.logDebug("destroying", scope: "ContainerPlugin")
        Logger.logDebug("destroying listeners", scope: "ContainerPlugin")
        stopListening()
        Logger.logDebug("destroyed", scope: "ContainerPlugin")
    }
}
