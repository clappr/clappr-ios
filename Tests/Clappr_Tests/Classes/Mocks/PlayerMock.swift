import AVFoundation

class PlayerMock: AVPlayer {
    private var accessLogEvent: AccessLogEventMock
    private var isFinished: Bool
    private var playerItemMock: PlayerItemMock
    
    override var currentItem: AVPlayerItem? { playerItemMock }
    
    init(accessLogEvent: AccessLogEventMock = AccessLogEventMock(), isFinished: Bool = false) {
        self.accessLogEvent = accessLogEvent
        self.isFinished = isFinished
        self.playerItemMock = PlayerItemMock(accessLogEvent: accessLogEvent, isFinished: isFinished)
            
        super.init()
    }
}
