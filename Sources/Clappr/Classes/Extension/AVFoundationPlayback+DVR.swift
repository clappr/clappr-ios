import AVFoundation

extension AVFoundationPlayback {
    open override var minDvrSize: Double {
        return options[kMinDvrSize] as? Double ?? 60.0
    }
    
    open override var isDvrInUse: Bool {
        if state == .paused && isDvrAvailable { return true }
        guard let end = dvrWindowEnd, playbackType == .live else { return false }
        guard let currentTime = player.currentItem?.currentTime().seconds else { return false }
        return end - liveHeadTolerance > currentTime
    }
    
    open override var isDvrAvailable: Bool {
        guard playbackType == .live else { return false }
        return duration >= minDvrSize
    }
    
    open override var currentDate: Date? {
        return player.currentItem?.currentDate()
    }

    open override var currentLiveDate: Date? {
        guard let currentDate = currentDate, playbackType == .live else { return nil }
        let liveDate = currentDate.timeIntervalSince1970 + (duration - TimeInterval(position))

        return Date(timeIntervalSince1970: liveDate)
    }
    
    open override var seekableTimeRanges: [NSValue] {
        guard let ranges = player.currentItem?.seekableTimeRanges else { return [] }
        return ranges
    }
    
    open override var loadedTimeRanges: [NSValue] {
        guard let ranges = player.currentItem?.loadedTimeRanges else { return [] }
        return ranges
    }
    
    open override var epochDvrWindowStart: TimeInterval {
        guard let currentDate = currentDate else { return 0 }
        return currentDate.timeIntervalSince1970 - position
    }
    
    var dvrWindowStart: Double? {
        guard let end = dvrWindowEnd, isDvrAvailable, playbackType == .live else { return nil }
        return end - duration
    }
    
    var dvrWindowEnd: Double? {
        guard isDvrAvailable, playbackType == .live else { return nil }
        return seekableTimeRanges.max { rangeA, rangeB in rangeA.timeRangeValue.end.seconds < rangeB.timeRangeValue.end.seconds }?.timeRangeValue.end.seconds
    }
    
    fileprivate var liveHeadTolerance: Double {
        return 5
    }
    
    func isEpochInsideDVRWindow(_ epoch: Double?) -> Bool {
        guard let epoch = epoch else { return false }
        
        let position = epoch - epochDvrWindowStart
        
        return position > 0 && position < duration
    }
}
