public protocol PluginInfo {
    func name() -> String
    func pluginType() -> PluginType
}