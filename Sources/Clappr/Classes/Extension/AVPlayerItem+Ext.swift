import AVKit

extension AVPlayerItem {
    func isFinished(with threshold: TimeInterval = 2.0) -> Bool {
        return fabs(CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime())) <= threshold
    }
}
