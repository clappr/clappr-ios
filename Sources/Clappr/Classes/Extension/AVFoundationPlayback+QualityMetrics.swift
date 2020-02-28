import AVFoundation

extension AVFoundationPlayback {
    private var lastLogEvent: AVPlayerItemAccessLogEvent? { player?.currentItem?.accessLog()?.events.last }

    open var bitrate: Double? { lastLogEvent?.indicatedBitrate }
    open var bandwidth: Double? { lastLogEvent?.observedBitrate }
    open var averageBitrate: Double? { lastLogEvent?.averageVideoBitrate }
    open var droppedFrames: Int? { lastLogEvent?.numberOfDroppedVideoFrames }
    open var totalFrames: Int? { 0 }
    open var domainHost: String? {
        guard let asset = player?.currentItem?.asset as? AVURLAsset else { return nil }
        return asset.url.host
    }
}
