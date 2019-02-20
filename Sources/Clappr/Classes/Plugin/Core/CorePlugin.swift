open class CorePlugin: BaseObject, Plugin {
    @objc open weak var core: Core?
    open class var type: PluginType { return .core }
    
    @objc open class var name: String {
        return self.init().pluginName
    }
    
    @objc open var pluginName: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "CorePlugin Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }
    
    public required override init() {
        super.init()
    }
    
    @objc public required init(context: UIObject) {
        super.init()
        if let container = context as? Core {
            self.core = container
        } else {
            NSException(name: NSExceptionName(rawValue: "WrongContextType"), reason: "Core Plugins should always be initialized with a Core context", userInfo: nil).raise()
        }
    }
    
    public func destroy() {
        Logger.logDebug("destroying", scope: "CorePlugin")
        Logger.logDebug("destroying listeners", scope: "CorePlugin")
        stopListening()
        Logger.logDebug("destroyed", scope: "CorePlugin")
    }
}
