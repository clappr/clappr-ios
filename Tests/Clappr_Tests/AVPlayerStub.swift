import AVFoundation

class AVPlayerStub: AVPlayer {

    override var currentItem: AVPlayerItem? {
        return _item
    }
    
    override func currentTime() -> CMTime {
        return _currentTime
    }
    
    private var _currentTime: CMTime = CMTime(seconds: 0, preferredTimescale: 0)
    
    var _item = AVPlayerItemStub(url: URL(string: "https://clappr.io/highline.mp4")!)

    func setStatus(to newStatus: AVPlayerItemStatus) {
        _item._status = newStatus
    }
    
    func set(currentTime: CMTime) {
        _currentTime = currentTime
    }
}
