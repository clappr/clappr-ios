public class ContainerFactory {
    private var sources: [NSURL]
    private var loader: Loader
 
    public init(sources: [NSURL], loader: Loader) {
        self.sources = sources
        self.loader = loader
    }
    
    public func createContainers() -> [Container] {
        return sources.flatMap(createContainer)
    }
    
    private func createContainer(url: NSURL) -> Container? {
        let availablePlaybacks = loader.playbackPlugins.filter({type in canPlay(type, url:url)})
        
        if availablePlaybacks.count == 0 {
            return nil
        }
        
        let t = availablePlaybacks[0] as! Playback.Type
        return Container(playback: t.init(url: url))
    }
    
    private func canPlay(type: AnyClass, url: NSURL) -> Bool {
        guard let type = type as? Playback.Type else {
            return false
        }
        
        return type.canPlay(url)
    }
}