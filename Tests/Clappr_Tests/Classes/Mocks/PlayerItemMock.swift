import AVFoundation

class PlayerItemMock: AVPlayerItem {
    private var itemAccessLog: AVPlayerItemAccessLog

    init(indicatedBitrate: Double, observedBitrate:  Double) {
        self.itemAccessLog = PlayerItemAccessLogMock(indicatedBitrate: indicatedBitrate, observedBitrate: observedBitrate)

        super.init(asset: AVAsset(url: URL(string: "http://clappr.sample/master.m3u8")!), automaticallyLoadedAssetKeys: nil)
    }

    override func accessLog() -> AVPlayerItemAccessLog? { itemAccessLog }
}
