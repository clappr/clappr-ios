import Foundation

struct ContainerFactory {
    static func create(with options: Options) -> Container {
        let container = Container(options: options)

        Loader.shared.containerPlugins.forEach { plugin in
            container.addPlugin(plugin.init(context: container))
        }

        return container
    }
}
