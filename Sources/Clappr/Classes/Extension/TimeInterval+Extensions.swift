import AVFoundation

extension TimeInterval {
    func seek() -> (time: CMTime, tolerance: CMTime) {
        let timeScale = Int32(NSEC_PER_SEC)
        let time = CMTimeMakeWithSeconds(self, preferredTimescale: timeScale)
        let tolerance = CMTime(value: 0, timescale: timeScale)
        return(time, tolerance)
    }
}
