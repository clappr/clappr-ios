import AVFoundation

class AVPlayerStub: AVPlayer {

    private var _currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: 0)
    var _item = AVPlayerItemStub(url: URL(string: "https://clappr.io/highline.mp4")!)

    override var currentItem: AVPlayerItem? {
        return _item
    }
    
    override func currentTime() -> CMTime {
        return _item.duration
    }

    func setStatus(to newStatus: AVPlayerItem.Status) {
        _item._status = newStatus
    }
    
    func set(currentTime: CMTime) {
        _item._duration = currentTime
    }
    
    func set(currentItem: AVPlayerItemStub) {
        _item = currentItem
    }
}
