open class ContainerPlugin: NSObject {
    @objc open weak var container: Container?

    open class var type: PluginType { return .container }

    @objc open class var name: String {
        return self.init().pluginName
    }

    @objc open var pluginName: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Container Plugins should always declare a name", userInfo: nil).raise()
        return ""
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
}
