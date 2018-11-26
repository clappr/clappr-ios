import Foundation

struct CoreFactory {
    static func create(with options: Options) -> Core {
        let core = Core(options: options)

        Loader.shared.corePlugins.forEach { plugin in
            if let corePlugin = plugin.init(context: core) as? UICorePlugin {
                core.addPlugin(corePlugin)
            }
        }

        return core
    }
}
