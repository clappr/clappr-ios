import AVFoundation

class PlayerItemAccessLogMock: AVPlayerItemAccessLog {
    private var accessLogEvent: AccessLogEventMock

    init(bitrate: Double) {
        self.accessLogEvent = AccessLogEventMock(bitrate: bitrate)
    }

    override var events: [AVPlayerItemAccessLogEvent] {
        return [accessLogEvent]
    }
}
