public class UIPlugin: UIBaseObject , PluginInfo {
    
    public func name() -> String {
        fatalError("Must Override Plugin Name information")
    }
    
    public func pluginType() -> PluginType {
        fatalError("Must Override Plugin Type information")
    }

    public var enabled = true {
        didSet {
            hidden = !enabled
            if !enabled {
                stopListening()
            }
        }
    }
    
    public func wasInstalled() {}
}