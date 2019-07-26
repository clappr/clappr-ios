import AVFoundation

extension AVFoundationPlayback {
    var lastLogEvent: AVPlayerItemAccessLogEvent? {
        return player?.currentItem?.accessLog()?.events.last
    }
}

extension AVPlayerItemAccessLogEvent {
    var bitrate: Double {
        if segmentsDownloadedDuration > 0 {
            return indicatedBitrate
        }
        return observedBitrate
    }
}
