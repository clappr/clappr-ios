import AVFoundation

class AVURLAssetStub: AVURLAsset {
    private var _duration: CMTime = CMTime(seconds: 0, preferredTimescale: 0)

    override var duration: CMTime {
        return _duration
    }

    func set(duration: CMTime) {
        _duration = duration
    }
}
