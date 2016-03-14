public class UIContainerPlugin: UIPlugin, Plugin {
    public weak var container: Container?
    
    class var type: PluginType { return .Container }
    
    class var name: String {
        return ""
    }
    
    var pluginName: String {
        NSException(name: "MissingPluginName", reason: "Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }
    
    public required init() {
        super.init(frame: CGRectZero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}