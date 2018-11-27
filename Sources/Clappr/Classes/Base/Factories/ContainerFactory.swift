import Foundation

struct ContainerFactory {
    static func create(with options: Options) -> Container {
        let container = Container(options: options)

        Loader.shared.containerPlugins.forEach { plugin in
            if let containerPlugin = plugin.init(context: container) as? UIContainerPlugin {
                container.addPlugin(containerPlugin)
            }
        }

        if let source = options[kSourceUrl] as? String {
            container.load(source)
        }

        return container
    }
}
