import Foundation

struct ContainerFactory {
    static func create(with options: Options, layerComposer: LayerComposer) -> Container {
        let container = Container(options: options, layerComposer: layerComposer)

        Loader.shared.containerPlugins.forEach { plugin in
            container.addPlugin(plugin.init(context: container))
        }

        return container
    }
}
