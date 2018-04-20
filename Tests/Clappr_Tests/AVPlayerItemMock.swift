import AVFoundation

class AVPlayerItemMock: AVPlayerItem {

    override var status: AVPlayerItemStatus {
        return _status
    }

    var didCallSeekWithCompletionHandler = false

    var _status: AVPlayerItemStatus = AVPlayerItemStatus.unknown

    override func seek(to time: CMTime, completionHandler: ((Bool) -> Void)?) {
        didCallSeekWithCompletionHandler = true
    }
}
