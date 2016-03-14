public class ContainerFactory {
    private var loader: Loader
    private var options: Options
 
    public init(loader: Loader = Loader(), options: Options = [:]) {
        self.loader = loader
        self.options = options
    }
    
    public func createContainer() -> Container? {
        var availablePlaybacks = loader.playbackPlugins.filter({type in canPlay(type)})
        
        if availablePlaybacks.count == 0 {
            return nil
        }
        
        let playback = availablePlaybacks[0] as! Playback.Type
        let container = Container(playback: playback.init(options: options), options: options)
        return addPlugins(container)
    }

    private func canPlay(type: Plugin.Type) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }
        
        return type.canPlay(self.options)
    }
    
    private func addPlugins(container: Container) -> Container {
        for type in loader.containerPlugins {
            container.addPlugin(type.init() as! UIContainerPlugin)
        }
        return container
    }
}