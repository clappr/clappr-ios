public class Player {
    public private(set) var core: Core
    
    public init(options: Options = [:], externalPlugins: [Plugin.Type] = []) {
        let loader = Loader(externalPlugins: externalPlugins)
        self.core = CoreFactory.create(loader , options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        view.addSubviewMatchingConstraints(core)
        core.parentController = controller
    }
}