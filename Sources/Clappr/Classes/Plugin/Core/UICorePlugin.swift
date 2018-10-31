open class UICorePlugin: UIPlugin, Plugin {
    @objc open weak var core: Core?

    open class var type: PluginType { return .core }

    @objc open class var name: String {
        return self.init().pluginName
    }

    @objc open var pluginName: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Core Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }

    public required override init() {
        super.init()
    }

    @objc public required init(context: UIBaseObject) {
        super.init()
        if let core = context as? Core {
            self.core = core
        } else {
            NSException(name: NSExceptionName(rawValue: "WrongContextType"), reason: "Core Plugins should always be initialized with a Core context", userInfo: nil).raise()
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "UICorePlugin")
        Logger.logDebug("destroying listeners", scope: "UICorePlugin")
        stopListening()
        Logger.logDebug("destroyed", scope: "UICorePlugin")
    }
}
