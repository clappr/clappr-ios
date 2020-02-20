import AVFoundation

class PlayerItemAccessLogMock: AVPlayerItemAccessLog {
    private var accessLogEvent: AccessLogEventMock

    init(accessLogEvent: AccessLogEventMock) {
        self.accessLogEvent = accessLogEvent
    }

    override var events: [AVPlayerItemAccessLogEvent] {
        return [accessLogEvent]
    }
}
