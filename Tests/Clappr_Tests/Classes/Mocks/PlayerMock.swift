import AVFoundation

class PlayerMock: AVPlayer {
    private var indicatedBitrate: Double
    private var observedBitrate: Double

    init(indicatedBitrate: Double = 0.0, observedBitrate: Double = 0.0) {
        self.indicatedBitrate = indicatedBitrate
        self.observedBitrate = observedBitrate

        super.init()
    }

    override var currentItem: AVPlayerItem? {
        return PlayerItemMock(indicatedBitrate: indicatedBitrate, observedBitrate: observedBitrate)
    }
}
