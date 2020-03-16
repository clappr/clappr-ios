import AVFoundation

class AccessLogEventMock: AVPlayerItemAccessLogEvent {
    private var _indicatedBitrate = 0.0
    private var _observedBitrate = 0.0
    private var _droppedFrames = 0

    init(_ initialize: Void = ()) { }

    func setIndicatedBitrate(_ indicatedBitrate: Double) {
        _indicatedBitrate = indicatedBitrate
    }

    func setObservedBitrate(_ observedBitrate: Double) {
        _observedBitrate = observedBitrate
    }

    func setDroppedFrames(_ droppedFrames: Int) {
        _droppedFrames = droppedFrames
    }

    override var indicatedBitrate: Double { _indicatedBitrate }
    override var observedBitrate: Double { _observedBitrate }
    override var numberOfDroppedVideoFrames: Int { _droppedFrames }
}
