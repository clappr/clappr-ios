import Foundation

struct ContainerFactory {
    static func create(with options: Options) -> Container {
        let container = Container(options: options)

        Loader.shared.containerPlugins.forEach { plugin in
            container.addPlugin(plugin.init(context: container))
        }

        if let source = options[kSourceUrl] as? String {
            container.load(source)
        }

        return container
    }
}
