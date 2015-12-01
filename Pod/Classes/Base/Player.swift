public class Player {
    public private(set) var sources: [NSURL]
    public private(set) var core: Core
    
    public convenience init(source: NSURL) {
        self.init(sources: [source])
    }
    
    public init(sources: [NSURL]) {
        self.sources = sources
        self.core = CoreFactory(sources: sources).create()
    }
    
    public func attachTo(view: UIView) {
        view.addSubviewMatchingContraints(core)
        core.load()
    }
}