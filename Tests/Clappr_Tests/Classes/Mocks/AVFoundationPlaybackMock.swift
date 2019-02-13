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
    
    func set(isPlaying: Bool) {
        _isPlaying = isPlaying
        _isPaused = !isPlaying
    }
    
    func set(isPaused: Bool) {
        _isPaused = isPaused
        _isPlaying = !isPaused
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
    
    override var isPlaying: Bool {
        return _isPlaying
    }
    
    override var isPaused: Bool {
        return _isPaused
    }
    
    override var position: Double {
        return videoPosition
    }
    
    override func pause() {
        didCallPause = true
        set(isPaused: true)
        super.pause()
    }
    
    override func play() {
        didCallPlay = true
        set(isPlaying: true)
        trigger(Event.playing)
    }
    
    override func stop() {
        didCallStop = true
        _isPlaying = false
        _isPaused = false
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
