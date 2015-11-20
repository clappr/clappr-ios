public class Loader {
    public static let sharedInstance = Loader()
    
    public var playbackPlugins: [AnyClass]
    public var containerPlugins: [AnyClass]
    public var corePlugins: [Plugin]
    
    public init() {
        playbackPlugins = []
        containerPlugins = []
        corePlugins = []
    }
}