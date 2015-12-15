public class CoreFactory {

    public class func create(sources: [NSURL], loader: Loader = Loader(), options: [String: AnyObject] = [:]) -> Core {
        let core = Core(sources: sources, loader: loader, options: options)
        for plugin in loader.corePlugins as! [UICorePlugin.Type] {
            core.addPlugin(plugin.init())
        }
        return core
    }
}