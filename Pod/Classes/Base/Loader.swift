public class Loader {
    public var playbackPlugins: [AnyClass]
    public var containerPlugins: [AnyClass]
    public var corePlugins: [AnyClass]
    
    public init() {
        playbackPlugins = [AVFoundationPlayback.self]
        containerPlugins = [LoadingContainerPlugin.self]
        corePlugins = []
    }
}