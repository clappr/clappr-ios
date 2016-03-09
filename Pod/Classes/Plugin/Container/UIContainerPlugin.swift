public class UIContainerPlugin: UIPlugin {
    public weak var container: Container?

    public override func pluginType() -> PluginType {
        return .Container
    }
}