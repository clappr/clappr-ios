@testable import Clappr

class CoreStub: Core {
    
    override var activeContainer: Container? {
        get {
            return _container
        }
        
        set {
            _container = activeContainer
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
