import AVFoundation

protocol AVPlayerItemInfoDelegate: AnyObject {
    func didLoadDuration()
    func didLoadCharacteristics()
}

class AVPlayerItemInfo {
    var item: AVPlayerItem
    weak var delegate: AVPlayerItemInfoDelegate?
    var assetInfo: AVAssetInfo
    
    var durationLoaded: Bool {
        item.status == .readyToPlay
    }
    
    private var observers = [NSKeyValueObservation]()
    
    init(item: AVPlayerItem, delegate: AVPlayerItemInfoDelegate) {
        self.item = item
        self.delegate = delegate
        self.assetInfo = AVAssetInfo(asset: item.asset)
        setupObservers()
    }
    
    func setupObservers() {
        waitForDuration()
        waitForCharacteristics()
    }
    
    var playbackType: PlaybackType {
        guard durationLoaded else {
            Logger.logDebug("Duration did not load - Unknown Playback", scope: "\(type(of: self))")
            return .unknown
        }
        return item.duration.isIndefinite ? .live : .vod
    }
    
    var duration: Double {
        switch playbackType {
        case .vod:
            return CMTimeGetSeconds(item.duration)
        case .live:
            return item.seekableTimeRanges.reduce(0.0) { $0 + $1.timeRangeValue.duration.seconds }
        default:
            return .zero
        }
    }
    
    /*
     The only way to definitely know if a video is VOD or LIVE is to wait for the AVPlayerItem status
     to become `readyToPlay` and then check it's duration. If the duration, at that moment, is
     CMTime.Indefinite, then the video is LIVE, otherwise it is VOD.
    */
    func waitForDuration() {
        observers = [
            item.observe(\.status) { [weak self] item, _ in
                if item.status == .readyToPlay {
                    self?.delegate?.didLoadDuration()
                }
            }
        ]
    }
    
    func waitForCharacteristics() {
        assetInfo.wait(for: .characteristics) { [weak self] in self?.delegate?.didLoadCharacteristics() }
    }
}
