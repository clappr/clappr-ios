public class Loader {
    public internal(set) var playbackPlugins: [Plugin.Type] = [AVFoundationPlayback.self, NoOpPlayback.self]
    public internal(set) var containerPlugins: [Plugin.Type] = [PosterPlugin.self, LoadingContainerPlugin.self]
    public internal(set) var corePlugins = [Plugin.Type]()
    public internal(set) var mediaControl: MediaControl.Type = MediaControl.self
    
    private var externalPlugins = [Plugin.Type]()
    
    public convenience init() {
        self.init(externalPlugins: [])
    }
    
    public init(externalPlugins: [Plugin.Type], options: Options = [:]) {
        self.externalPlugins = externalPlugins

        loadExternalMediaControl(options)
        
        if !externalPlugins.isEmpty {
            addExternalPlugins(externalPlugins)
        }

        Logger.logInfo("plugins:\n - playback: \(playbackPlugins)\n - container: \(containerPlugins)\n - core: \(corePlugins)\n - mediaControl: \(mediaControl)", scope: "\(self.dynamicType)")
    }
    
    private func loadExternalMediaControl(options: Options) {
        if let externalMediaControl = options[kMediaControl] as? MediaControl.Type {
            mediaControl = externalMediaControl
        }
    }
    
    public func addExternalPlugins(externalPlugins: [Plugin.Type]) {
        self.externalPlugins = externalPlugins
        playbackPlugins = getPlugins(.Playback, defaultPlugins: playbackPlugins)
        containerPlugins = getPlugins(.Container, defaultPlugins: containerPlugins)
        corePlugins = getPlugins(.Core, defaultPlugins: corePlugins)
    }
    
    private func getPlugins(type: PluginType, defaultPlugins: [Plugin.Type]) -> [Plugin.Type] {
        let filteredPlugins = externalPlugins.filter({$0.type == type})
        return removeDuplicate(filteredPlugins + defaultPlugins)
    }
    
    private func removeDuplicate(plugins: [Plugin.Type]) -> [Plugin.Type] {
        var result = [Plugin.Type]()
        
        for plugin in plugins {
            if !result.contains({$0.name == plugin.name}) {
                result.append(plugin)
            }
        }
        
        return result
    }
}