public class Player {
    public private(set) var core: Core
    
    public convenience init(source: NSURL, loader: Loader = Loader(), options: Options = [:]) {
        self.init(sources: [source], loader: loader, options: options)
    }
    
    public init(sources: [NSURL], loader: Loader = Loader(), options: Options = [:]) {
        self.core = CoreFactory.create(sources, loader: loader, options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        view.addSubviewMatchingConstraints(core)
        core.parentController = controller
    }
}