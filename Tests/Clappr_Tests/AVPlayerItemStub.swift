import AVFoundation

class AVPlayerItemStub: AVPlayerItem {

    var _seekableTimeRanges: [NSValue] = []
    
    var didCallSeekWithCompletionHandler = false

    var _status: AVPlayerItemStatus = AVPlayerItemStatus.unknown

    override func seek(to time: CMTime, completionHandler: ((Bool) -> Void)?) {
        didCallSeekWithCompletionHandler = true
        completionHandler!(true)
    }

    override var seekableTimeRanges: [NSValue] {
        return _seekableTimeRanges
    }

    override var status: AVPlayerItemStatus {
        return _status
    }
    
    func setSeekableTimeRange(with duration: Double) {        
        let startCMTime = CMTime(seconds: 0, preferredTimescale: 1)
        let durationCMTime = CMTime(seconds: duration, preferredTimescale: 1)
        let cmTimeRange = CMTimeRange(start: startCMTime, duration: durationCMTime)
        let timeRangeValue = NSValue(timeRange: cmTimeRange)
        let seekableTimeRanges = [timeRangeValue]
        _seekableTimeRanges = seekableTimeRanges
    }
}
