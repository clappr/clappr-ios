import AVFoundation

class AVPlayerStub: AVPlayer {

    override var currentItem: AVPlayerItem? {
        return _item
    }

    var _item = AVPlayerItemStub(url: URL(string: "https://clappr.io/highline.mp4")!)

    func setStatus(to newStatus: AVPlayerItemStatus) {
        _item._status = newStatus
    }
}
