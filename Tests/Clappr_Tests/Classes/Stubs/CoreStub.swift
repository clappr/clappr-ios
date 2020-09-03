@testable import Clappr

class CoreStub: Core {
    
    init() {
        super.init(options: [:], layerComposer: LayerComposer())
    }
    
    required init(options: Options = [:], layerComposer: LayerComposer) {
        super.init(options: options, layerComposer: layerComposer)
    }
    
    override var activeContainer: Container? {
        get {
            return _container
        }
        set {
            _container = newValue
        }
    }
    
    override var activePlayback: Playback? {
        return activeContainer?.playback
    }
    
    var playbackMock: AVFoundationPlaybackMock? {
        return activePlayback as? AVFoundationPlaybackMock
    }
    
    var _container: Container? = ContainerStub()
    
    func setDvrAvailability(availability: Bool) {
        playbackMock?._isDvrAvailable = availability
    }
    
}
