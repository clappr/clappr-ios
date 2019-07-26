import AVFoundation

extension AVFoundationPlayback {
    open var bitrate: Double? {
        return lastLogEvent?.bitrate
    }
    
    open var averageBitrate: Double? {
        return lastLogEvent?.averageVideoBitrate
    }
    
    private var lastLogEvent: AVPlayerItemAccessLogEvent? {
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
