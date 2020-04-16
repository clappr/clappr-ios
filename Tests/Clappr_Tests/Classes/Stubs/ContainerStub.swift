@testable import Clappr

class ContainerStub: Container {
    var didCallPlay = false
    var didCallPause = false
    
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
    
    override func play() {
        let playbackMock = _playback as! AVFoundationPlaybackMock
        
        playbackMock.set(state: .playing)
        
        playback?.trigger(.playing)
        didCallPlay = true
    }
    
    override func pause() {
        let playbackMock = _playback as! AVFoundationPlaybackMock
        
        playbackMock.set(state: .paused)
        
        playback?.trigger(.didPause)
        didCallPause = true
    }
    
    var _playback: Playback? = AVFoundationPlaybackMock(options:[:])
}
