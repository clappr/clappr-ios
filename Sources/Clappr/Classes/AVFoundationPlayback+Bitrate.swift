import AVFoundation

extension AVFoundationPlayback {
    public func getBitrate() -> Double? {
        guard let logEvent = lastLogEvent() else { return nil }
        if (logEvent.segmentsDownloadedDuration ) > 0 {
            return logEvent.indicatedBitrate
        }
        return logEvent.observedBitrate
    }

    public func getAvgBitrate() -> Double? {
        guard let logEvent = lastLogEvent() else { return nil }
        return logEvent.averageVideoBitrate
    }

    private func lastLogEvent() -> AVPlayerItemAccessLogEvent? {
        return player?.currentItem?.accessLog()?.events.last
    }
}
