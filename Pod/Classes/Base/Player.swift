public class Player {
    public private(set) var core: Core
    
    public convenience init(source: NSURL, loader: Loader = Loader(), options: [String: AnyObject] = [:]) {
        self.init(sources: [source], loader: loader, options: options)
    }
    
    public init(sources: [NSURL], loader: Loader = Loader(), options: [String: AnyObject] = [:]) {
        self.core = CoreFactory.create(sources, loader: loader, options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        view.addSubviewMatchingContraints(core)
        core.parentController = controller
    }
}