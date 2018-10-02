@testable import Clappr

class ContainerStub: Container {
    override var playback: Playback? {
        get {
            return _playback
        }
        set {
            _playback = newValue
        }
    }
    
    var _playback: Playback? = AVFoundationPlaybackMock()
}
