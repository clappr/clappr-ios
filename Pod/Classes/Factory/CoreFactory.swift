public class CoreFactory {

    public class func create(loader: Loader = Loader(), options: Options = [:]) -> Core {
        let core = Core(loader: loader, options: options)
        for plugin in loader.corePlugins {
            core.addPlugin(plugin.init() as! UICorePlugin)
        }
        return core
    }
}