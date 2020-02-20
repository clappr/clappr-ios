import AVFoundation

class PlayerMock: AVPlayer {
    private var accessLogEvent: AccessLogEventMock

    init(accessLogEvent: AccessLogEventMock) {
        self.accessLogEvent = accessLogEvent
        super.init()
    }

    override var currentItem: AVPlayerItem? { PlayerItemMock(accessLogEvent: accessLogEvent) }
}
