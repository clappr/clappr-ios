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
    
    override func trigger(_ eventName: String) {
        super.trigger(eventName)
    }
    
    var _playback: Playback? = AVFoundationPlaybackMock(options:[:])
}
