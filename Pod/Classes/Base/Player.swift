public class Player {
    public private(set) var sources: [NSURL]
    public private(set) var core: Core
    
    public convenience init(source: NSURL, loader: Loader = Loader()) {
        self.init(sources: [source], loader: loader)
    }
    
    public init(sources: [NSURL], loader: Loader = Loader()) {
        self.sources = sources
        self.core = CoreFactory(sources: sources, loader: loader).create()
    }
    
    public func attachTo(view: UIView) {
        view.addSubviewMatchingContraints(core)
        core.load()
    }
}