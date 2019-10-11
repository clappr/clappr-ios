import AVKit

extension AVPlayerItem {
    func isFinished(with threshold: TimeInterval = 2.0) -> Bool {
        return fabs(CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime())) <= threshold
    }

    func seek(to timeInterval: TimeInterval, _ completion: (() -> Void)? = nil) {
        let time = timeInterval.seek().time
        let tolerance = timeInterval.seek().tolerance
        seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance) { success in
            if success {
                completion?()
            }
        }
    }
}
