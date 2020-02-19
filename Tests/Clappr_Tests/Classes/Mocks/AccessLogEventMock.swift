import AVFoundation

class AccessLogEventMock: AVPlayerItemAccessLogEvent {
    var bitrate: Double

    init(bitrate: Double) {
        self.bitrate = bitrate
    }

    override var indicatedBitrate: Double { bitrate }
}
