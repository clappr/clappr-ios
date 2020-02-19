import AVFoundation

class PlayerMock: AVPlayer {
    private var bitrate: Double

    init(bitrate: Double = 0.0) {
        self.bitrate = bitrate

        super.init()
    }

    override var currentItem: AVPlayerItem? {
        return PlayerItemMock(bitrate: bitrate)
    }
}
