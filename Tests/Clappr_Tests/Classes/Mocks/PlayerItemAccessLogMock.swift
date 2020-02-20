import AVFoundation

class PlayerItemAccessLogMock: AVPlayerItemAccessLog {
    private var accessLogEvent: AccessLogEventMock

    init(indicatedBitrate: Double, observedBitrate: Double) {
        self.accessLogEvent = AccessLogEventMock(indicatedBitrate: indicatedBitrate, observedBitrate: observedBitrate)
    }

    override var events: [AVPlayerItemAccessLogEvent] {
        return [accessLogEvent]
    }
}
