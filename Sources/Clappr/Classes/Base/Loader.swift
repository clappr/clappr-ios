open class Loader {
    
    static let shared = Loader()
    
    internal(set) open var playbacks: [Plugin.Type] = [AVFoundationPlayback.self, NoOpPlayback.self]
    #if os (iOS)
    internal(set) open var containerPlugins: [Plugin.Type] = [PosterPlugin.self, SpinnerPlugin.self]
    #else
    internal(set) open var containerPlugins: [Plugin.Type] = []
    #endif
    internal(set) open var corePlugins = [Plugin.Type]()
    
    var externalPlugins: [Plugin.Type] = []
    
    private init() {
        Logger.logInfo("plugins:" +
            "\n - playback: \(playbacks.map({ $0.name }))" +
            "\n - container: \(containerPlugins.map({ $0.name }))" +
            "\n - core: \(corePlugins.map({ $0.name }))")
    }
    
    open func addExternalPlugins(_ externalPlugins: [Plugin.Type]) {
        self.externalPlugins.append(contentsOf: externalPlugins)
        self.externalPlugins = self.removeDuplicate(self.externalPlugins)
        playbacks = getPlugins(.playback, defaultPlugins: playbacks)
        containerPlugins = getPlugins(.container, defaultPlugins: containerPlugins)
        corePlugins = getPlugins(.core, defaultPlugins: corePlugins)
    }
    
    private func getPlugins(_ type: PluginType, defaultPlugins: [Plugin.Type]) -> [Plugin.Type] {
        let filteredPlugins = externalPlugins.filter({ $0.type == type })
        return removeDuplicate(filteredPlugins + defaultPlugins)
    }
    
    private func removeDuplicate(_ plugins: [Plugin.Type]) -> [Plugin.Type] {
        var result = [Plugin.Type]()
        
        for plugin in plugins {
            if !result.contains(where: { $0.name == plugin.name }) {
                result.append(plugin)
            }
        }
        
        return result
    }
}
