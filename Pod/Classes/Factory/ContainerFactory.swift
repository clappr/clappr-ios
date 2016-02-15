public class ContainerFactory {
    private var loader: Loader
    private var options: Options
    private var plugins: [AnyClass]
 
    public init(loader: Loader, options: Options = [:]) {
        self.loader = loader
        self.options = options
        self.plugins = loader.containerPlugins.filter({ $0 is UIContainerPlugin.Type })
    }
    
    public func createContainer() -> Container? {
        var availablePlaybacks = self.availablePlaybacks()
        
        if availablePlaybacks.count == 0 {
            return nil
        }
        
        let container = Container(playback: availablePlaybacks[0].init(options: options), options: options)
        return addPlugins(container)
    }
    
    private func availablePlaybacks() -> [Playback.Type] {
        let availablePlaybacks = loader.playbackPlugins.filter({type in canPlay(type)})
        return availablePlaybacks as! [Playback.Type]
    }
    
    private func canPlay(type: AnyClass) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }
        
        return type.canPlay(self.options)
    }
    
    private func addPlugins(container: Container) -> Container {
        for type in plugins as! [UIContainerPlugin.Type]{
            container.addPlugin(type.init())
        }
        return container
    }
}