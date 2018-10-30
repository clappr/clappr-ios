open class Loader {

    public static let shared = Loader()
    public var plugins: [Plugin.Type] = []

    var playbacks: [Plugin.Type] {
        return plugins.filter { $0.type == .playback }.map { return $0 }
    }

    var containerPlugins: [Plugin.Type] {
        return plugins.filter { $0.type == .container }.map { return $0 }
    }

    var corePlugins: [Plugin.Type] {
        return plugins.filter { $0.type == .core }.map { return $0 }
    }

    private init() {
        Logger.logInfo("plugins:" +
            "\n - playback: \(playbacks.map({ $0.name }))" +
            "\n - container: \(containerPlugins.map({ $0.name }))" +
            "\n - core: \(corePlugins.map({ $0.name }))")
    }

    open func register(plugins: [Plugin.Type]) {
        self.plugins.appendOrReplace(contentsOf: plugins)
    }

    open func loadPlugins(in core: Core) {
        for plugin in Loader.shared.corePlugins {
            if let corePlugin = plugin.init(context: core) as? UICorePlugin {
                core.addPlugin(corePlugin)
            }
        }
    }

    open func loadPlugins(in container: Container) {
        for plugin in Loader.shared.containerPlugins {
            if let containerPlugin = plugin.init(context: container) as? UIContainerPlugin {
                container.addPlugin(containerPlugin)
            }
        }
    }
}
