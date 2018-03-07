open class Loader {
    internal(set) open var playbackPlugins: [Plugin.Type] = [AVFoundationPlayback.self, NoOpPlayback.self]
    #if os (iOS)
    internal(set) open var containerPlugins: [Plugin.Type] = [PosterPlugin.self, SpinnerPlugin.self]
    #else
    internal(set) open var containerPlugins: [Plugin.Type] = []
    #endif
    internal(set) open var corePlugins = [Plugin.Type]()
    internal(set) open var mediaControl: MediaControl.Type = MediaControl.self

    fileprivate var externalPlugins = [Plugin.Type]()

    public convenience init() {
        self.init(externalPlugins: [])
    }

    public init(externalPlugins: [Plugin.Type], options: Options = [:]) {
        self.externalPlugins = externalPlugins

        loadExternalMediaControl(options)

        if !externalPlugins.isEmpty {
            addExternalPlugins(externalPlugins)
        }

        Logger.logInfo("plugins:" +
            "\n - playback: \(playbackPlugins.map({ $0.name }))" +
            "\n - container: \(containerPlugins.map({ $0.name }))" +
            "\n - core: \(corePlugins.map({ $0.name }))" +
            "\n - mediaControl: \(mediaControl)", scope: "\(type(of: self))")
    }

    fileprivate func loadExternalMediaControl(_ options: Options) {
        if let externalMediaControl = options[kMediaControl] as? MediaControl.Type {
            mediaControl = externalMediaControl
        }
    }

    open func addExternalPlugins(_ externalPlugins: [Plugin.Type]) {
        self.externalPlugins = externalPlugins
        playbackPlugins = getPlugins(.playback, defaultPlugins: playbackPlugins)
        containerPlugins = getPlugins(.container, defaultPlugins: containerPlugins)
        corePlugins = getPlugins(.core, defaultPlugins: corePlugins)
    }

    fileprivate func getPlugins(_ type: PluginType, defaultPlugins: [Plugin.Type]) -> [Plugin.Type] {
        let filteredPlugins = externalPlugins.filter({ $0.type == type })
        return removeDuplicate(filteredPlugins + defaultPlugins)
    }

    fileprivate func removeDuplicate(_ plugins: [Plugin.Type]) -> [Plugin.Type] {
        var result = [Plugin.Type]()

        for plugin in plugins {
            if !result.contains(where: { $0.name == plugin.name }) {
                result.append(plugin)
            }
        }

        return result
    }
}
