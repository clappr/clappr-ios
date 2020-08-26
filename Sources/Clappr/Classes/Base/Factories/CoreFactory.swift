import Foundation

struct CoreFactory {
    static func create(with options: Options, layersCompositor: LayersCompositor) -> Core {
        let core = Core(options: options, layersCompositor: layersCompositor)
        
        let container = ContainerFactory.create(with: options)
        core.add(container: container)
        core.setActive(container: container)
        
        return core
    }
}
