import AVFoundation

class AVPlayerStub: AVPlayer {

    private var _currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: 0)
    var _item = AVPlayerItemStub(url: URL(string: "https://clappr.io/highline.mp4")!)

    override var currentItem: AVPlayerItem? {
        return _item
    }
    
    override func currentTime() -> CMTime {
        return _currentTime
    }

    func setStatus(to newStatus: AVPlayerItemStatus) {
        _item._status = newStatus
    }
    
    func set(currentTime: CMTime) {
        _currentTime = currentTime
    }
    
    func set(currentItem: AVPlayerItemStub) {
        _item = currentItem
    }
}
