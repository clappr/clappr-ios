public class Loader {
    public static let sharedInstance = Loader()
    
    public internal(set) var playbackPlugins: [Playback]
    public internal(set) var containerPlugins: [UIContainerPlugin]
    public internal(set) var corePlugins: [Plugin]
    
    init() {
        playbackPlugins = []
        containerPlugins = []
        corePlugins = []
    }
}