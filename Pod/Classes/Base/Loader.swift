public class Loader {
    public var playbackPlugins: [AnyClass]
    public var containerPlugins: [AnyClass]
    public var corePlugins: [AnyClass]
    public var mediaControl: MediaControl.Type
    
    public init() {
        playbackPlugins = [AVFoundationPlayback.self]
        containerPlugins = [PosterPlugin.self, LoadingContainerPlugin.self]
        corePlugins = []
        mediaControl = MediaControl.self
    }
}