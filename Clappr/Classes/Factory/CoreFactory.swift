public class CoreFactory {

    public class func create(_ loader: Loader = Loader(), options: Options = [:]) -> Core {
        let core = Core(loader: loader, options: options)
        for plugin in loader.corePlugins {
            core.addPlugin(plugin.init(context: core) as! UICorePlugin)
        }
        return core
    }
}
