import AVKit

extension AVPlayerItem {
    private var threshold: TimeInterval {
        return 2.0
    }

    var isFinished: Bool {
        return fabs(CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime())) <= threshold
    }
}
