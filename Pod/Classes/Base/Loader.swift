public class Loader {
    public var playbackPlugins: [Plugin.Type] = [AVFoundationPlayback.self]
    public var containerPlugins: [Plugin.Type] = [PosterPlugin.self, LoadingContainerPlugin.self]
    public var corePlugins = [Plugin.Type]()
    public var mediaControl: MediaControl.Type = MediaControl.self
    
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