import AVFoundation

class AVPlayerItemStub: AVPlayerItem {

    var _seekableTimeRanges: [NSValue] = []
    var _loadedTimeRanges: [NSValue] = []

    var _duration: CMTime = CMTime(seconds: 0, preferredTimescale: 0)

    var _currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: 0)
    
    var didCallSeekWithCompletionHandler = false
    var didCallSeekWithTime: CMTime?

    var _status: AVPlayerItem.Status = AVPlayerItem.Status.unknown

    var _currentDate: Date = Date()

    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: ((Bool) -> Void)?) {
        didCallSeekWithCompletionHandler = true
        didCallSeekWithTime = time
        completionHandler!(true)
    }

    override var seekableTimeRanges: [NSValue] {
        return _seekableTimeRanges
    }

    override var loadedTimeRanges: [NSValue] {
        return _loadedTimeRanges
    }

    override var status: AVPlayerItem.Status {
        return _status
    }

    func createTimeRangeValue(with duration: Double, start: Double = 0) -> CMTimeRange {
        let startCMTime = CMTime(seconds: start, preferredTimescale: 1)
        let durationCMTime = CMTime(seconds: duration, preferredTimescale: 1)
        return CMTimeRange(start: startCMTime, duration: durationCMTime)
    }

    func setSeekableTimeRange(with duration: Double) {
        _seekableTimeRanges = [NSValue(timeRange: createTimeRangeValue(with: duration))]
    }

    func setWindow(start: Double, end: Double) {
        _seekableTimeRanges = [NSValue(timeRange: createTimeRangeValue(with: end - start, start: start))]
    }

    func setLoadedTimeRanges(with duration: Double) {
        _loadedTimeRanges = [NSValue(timeRange: createTimeRangeValue(with: duration))]
    }

    func set(currentDate: Date) {
        _currentDate = currentDate
    }

    override var duration: CMTime {
        return _duration
    }

    override func currentTime() -> CMTime {
        return _currentTime
    }

    override func currentDate() -> Date? {
        return _currentDate
    }
}
