public class CoreFactory {
    private var sources: [NSURL]
    private var loader: Loader
    
    public init(sources: [NSURL], loader: Loader = Loader()) {
        self.sources = sources
        self.loader = loader
    }
    
    public func create() -> Core {
        let core = Core(sources: sources, loader: loader)
        for plugin in loader.corePlugins as! [UICorePlugin.Type] {
            core.addPlugin(plugin.init())
        }
        return core
    }
}