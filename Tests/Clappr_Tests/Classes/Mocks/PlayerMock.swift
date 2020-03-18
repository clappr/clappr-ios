import AVFoundation

class PlayerMock: AVPlayer {
    private var accessLogEvent: AccessLogEventMock
    private var isFinished: Bool
    private var _playerItem: PlayerItemMock
    
    init(accessLogEvent: AccessLogEventMock, isFinished: Bool = false) {
        self.accessLogEvent = accessLogEvent
        self.isFinished = isFinished
        self._playerItem = PlayerItemMock(accessLogEvent: accessLogEvent, isFinished: isFinished)
            
        super.init()
    }

    override var currentItem: AVPlayerItem? { _playerItem }
}
