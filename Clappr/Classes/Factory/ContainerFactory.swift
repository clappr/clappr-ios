public class ContainerFactory {
    private var loader: Loader
    private var options: Options
 
    public init(loader: Loader = Loader(), options: Options = [:]) {
        self.loader = loader
        self.options = options
    }
    
    public func createContainer() -> Container {
        let playbackFactory = PlaybackFactory(loader: loader, options: options)
        let container = Container(playback: playbackFactory.createPlayback(), loader: loader, options: options)
        return container
    }
}
