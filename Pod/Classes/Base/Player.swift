public class Player {
    public private(set) var core: Core
    
    public init(loader: Loader = Loader(), options: Options = [:]) {
        self.core = CoreFactory.create(loader, options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        view.addSubviewMatchingConstraints(core)
        core.parentController = controller
    }
}