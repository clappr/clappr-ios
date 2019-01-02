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
        if #available(iOS 10.0, *) {
            return logEvent.averageVideoBitrate
        }
        return nil
    }

    private func lastLogEvent() -> AVPlayerItemAccessLogEvent? {
        return player?.currentItem?.accessLog()?.events.last
    }
}
