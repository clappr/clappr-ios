import AVFoundation

class AVPlayerItemStub: AVPlayerItem {

    var _seekableTimeRanges: [NSValue] = []
    var _loadedTimeRanges: [NSValue] = []

    var _duration: CMTime = CMTime(seconds: 0, preferredTimescale: 0)
    
    var didCallSeekWithCompletionHandler = false

    var _status: AVPlayerItemStatus = AVPlayerItemStatus.unknown

    override func seek(to time: CMTime, completionHandler: ((Bool) -> Void)?) {
        didCallSeekWithCompletionHandler = true
        completionHandler!(true)
    }

    override var seekableTimeRanges: [NSValue] {
        return _seekableTimeRanges
    }

    override var loadedTimeRanges: [NSValue] {
        return _loadedTimeRanges
    }

    override var status: AVPlayerItemStatus {
        return _status
    }

    func createTimeRangeValue(with duration: Double) -> CMTimeRange {
        let startCMTime = CMTime(seconds: 0, preferredTimescale: 1)
        let durationCMTime = CMTime(seconds: duration, preferredTimescale: 1)
        return CMTimeRange(start: startCMTime, duration: durationCMTime)
    }

    func setSeekableTimeRange(with duration: Double) {        
        _seekableTimeRanges = [NSValue(timeRange: createTimeRangeValue(with: duration))]
    }

    func setLoadedTimeRanges(with duration: Double) {
        _loadedTimeRanges = [NSValue(timeRange: createTimeRangeValue(with: duration))]
    }

    override var duration: CMTime {
        return _duration
    }
}
