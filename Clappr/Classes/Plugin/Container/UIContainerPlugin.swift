open class UIContainerPlugin: UIPlugin, Plugin {
    open weak var container: Container!

    open class var type: PluginType { return .container }

    open class var name: String {
        return self.init().pluginName
    }

    open var pluginName: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Container Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }

    public required init() {
        super.init(frame: CGRect.zero)
    }

    public required init(context: UIBaseObject) {
        super.init(frame: CGRect.zero)
        if let container = context as? Container {
            self.container = container
        } else {
            NSException(name: NSExceptionName(rawValue: "WrongContextType"), reason: "Container Plugins should always be initialized with a Container context", userInfo: nil).raise()
        }
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
