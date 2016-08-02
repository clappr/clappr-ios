public class UICorePlugin: UIPlugin, Plugin {
    public weak var core: Core!
    
    public class var type: PluginType { return .Core }
    
    public class var name: String {
        return self.init().pluginName
    }
    
    public var pluginName: String {
        NSException(name: "MissingPluginName", reason: "Core Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }
    
    public required init() {
        super.init(frame: CGRectZero)
    }

    public required init(context: UIBaseObject) {
        super.init(frame: CGRectZero)
        if let core = context as? Core {
            self.core = core
        } else {
            NSException(name: "WrongContextType", reason: "Core Plugins should always be initialized with a Core context", userInfo: nil).raise()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}