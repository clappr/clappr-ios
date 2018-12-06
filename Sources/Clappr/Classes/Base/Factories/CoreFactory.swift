import Foundation

struct CoreFactory {
    static func create(with options: Options) -> Core {
        let core = Core(options: options)
        
        let container = ContainerFactory.create(with: options)
        core.add(container: container)
        core.setActive(container: container)
        
        return core
    }
}
