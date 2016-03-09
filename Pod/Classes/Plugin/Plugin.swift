public class Plugin: BaseObject, PluginInfo {

    public func name() -> String {
        fatalError("Must Override Plugin Name information")
    }
    
    public func pluginType() -> PluginType {
        fatalError("Must Override Plugin Type information")
    }
    
}