public class ContainerFactory {
    private var source: NSURL?
    private var loader: Loader
    private var options: Options
    private var plugins: [AnyClass]
 
    public init(loader: Loader, options: Options = [:]) {
        if let urlString = options[kSourceUrl] as? String {
            self.source = NSURL(string: urlString)
        }
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
        var availablePlaybacks: [AnyObject]
        
        if let url = source {
            availablePlaybacks = loader.playbackPlugins.filter({type in canPlay(type, url:url)})
        } else {
            availablePlaybacks = loader.playbackPlugins
        }
        
        return availablePlaybacks as! [Playback.Type]
    }
    
    private func canPlay(type: AnyClass, url: NSURL) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }
        
        return type.canPlay(url)
    }
    
    private func addPlugins(container: Container) -> Container {
        for type in plugins as! [UIContainerPlugin.Type]{
            container.addPlugin(type.init())
        }
        return container
    }
}