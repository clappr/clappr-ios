import AVFoundation

class PlayerItemMock: AVPlayerItem {
    private var itemAccessLog: AVPlayerItemAccessLog

    init(bitrate: Double) {
        self.itemAccessLog = PlayerItemAccessLogMock(bitrate: bitrate)

        super.init(asset: AVAsset(url: URL(string: "http://clappr.sample/master.m3u8")!), automaticallyLoadedAssetKeys: nil)
    }

    override func accessLog() -> AVPlayerItemAccessLog? { itemAccessLog }
}
