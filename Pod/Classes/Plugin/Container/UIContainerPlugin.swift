public class UIContainerPlugin: UIPlugin, Plugin {
    public weak var container: Container!
    
    public class var type: PluginType { return .Container }
    
    public class var name: String {
        return self.init().pluginName
    }
    
    public var pluginName: String {
        NSException(name: "MissingPluginName", reason: "Container Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }
    
    public required init() {
        super.init(frame: CGRectZero)
    }
    
    public required init(context: UIBaseObject) {
        super.init(frame: CGRectZero)
        if let container = context as? Container {
            self.container = container
        } else {
           NSException(name: "WrongContextType", reason: "Container Plugins should always be initialized with a Container context", userInfo: nil).raise()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}