import AVFoundation

class AccessLogEventMock: AVPlayerItemAccessLogEvent {
    private var _indicatedBitrate: Double
    private var _observedBitrate: Double

    init(indicatedBitrate: Double, observedBitrate: Double) {
        _indicatedBitrate = indicatedBitrate
        _observedBitrate = observedBitrate
    }

    override var indicatedBitrate: Double { _indicatedBitrate }
    override var observedBitrate: Double { _observedBitrate }
}
