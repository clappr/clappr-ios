import Foundation

struct CoreFactory {
    static func create(with options: Options, layerComposer: LayerComposer) -> Core {
        let core = Core(options: options, layerComposer: layerComposer)
        
        let container = ContainerFactory.create(with: options, layerComposer: layerComposer)
        core.add(container: container)
        core.setActive(container: container)
        
        return core
    }
}
