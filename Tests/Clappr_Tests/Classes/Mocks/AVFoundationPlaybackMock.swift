@testable import Clappr
import AVFoundation

class AVFoundationPlaybackMock: AVFoundationPlayback {
    var didCallPause = false
    var didCallStop = false
    var didCallPlay = false
    var videoDuration: Double = 0
    var didCallSeek = false
    var didCallSeekWithValue: TimeInterval = 0
    var _isPlaying = false
    var _isPaused = false
    var removeObserverCalls = 0
    var _currentDate: Date?
    var _isDvrAvailable = false
    var videoPosition: Double = 0
    var _isDvrInUse = false
    var didCallSeekToLivePosition = false
    var _playbackType: PlaybackType = .vod
    var _state: PlaybackState = .none

    override open var state: PlaybackState {
        get {
            return _state
        }
        set {
            _state = newValue
        }
    }
    
    override var duration: Double {
        return videoDuration
    }
    
    override var isDvrAvailable: Bool {
        return _isDvrAvailable
    }
    
    override var isDvrInUse: Bool {
        return _isDvrInUse
    }
    
    override var playbackType: PlaybackType {
        return _playbackType
    }

    func set(state: PlaybackState) {
        _state = state
    }

    func set(isDvrInUse: Bool) {
        _isDvrInUse = isDvrInUse
    }
    
    func set(isDvrAvailable: Bool) {
        _isDvrAvailable = isDvrAvailable
    }
    
    func set(playbackType: PlaybackType) {
        _playbackType = playbackType
    }
    
    func set(position: Double) {
        videoPosition = position
    }
    
    override var position: Double {
        return videoPosition
    }
    
    override func pause() {
        didCallPause = true
        set(state: .paused)
        super.pause()
    }
    
    override func play() {
        didCallPlay = true
        set(state: .playing)
        trigger(Event.playing)
        super.play()
    }
    
    override func stop() {
        didCallStop = true
        set(state: .idle)
        super.stop()
    }
    
    override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        removeObserverCalls += 1
    }
    
    override func seek(_ timeInterval: TimeInterval) {
        super.seek(timeInterval)
        didCallSeek = true
        didCallSeekWithValue = timeInterval
    }
    
    override var currentDate: Date? {
        return _currentDate
    }
    
    #if os(iOS)
    override func seekToLivePosition() {
        didCallSeekToLivePosition = true
    }
    #endif
    
}
