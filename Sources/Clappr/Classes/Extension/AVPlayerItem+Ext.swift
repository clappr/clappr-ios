import AVKit

extension AVPlayerItem {
    func isFinished(with threshold: TimeInterval = 2.0) -> Bool {
        return fabs(CMTimeGetSeconds(duration) - CMTimeGetSeconds(currentTime())) <= threshold
    }

    func seek(to timeInterval: TimeInterval, _ completion: (() -> Void)? = nil) {
        seek(
            to: timeInterval.seek().time,
            toleranceBefore: timeInterval.seek().tolerance,
            toleranceAfter: timeInterval.seek().tolerance
        ) { success in
            if success { completion?() }
        }
    }
}
