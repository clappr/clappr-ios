public class UICorePlugin: UIPlugin {
    public weak var core: Core?
    
    public override func pluginType() -> PluginType {
        return .Core
    }
}