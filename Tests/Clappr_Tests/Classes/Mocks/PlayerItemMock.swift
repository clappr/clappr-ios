import AVFoundation

class PlayerItemMock: AVPlayerItem {
    private var itemAccessLog: AVPlayerItemAccessLog

    init(accessLogEvent: AccessLogEventMock) {
        self.itemAccessLog = PlayerItemAccessLogMock(accessLogEvent: accessLogEvent)

        super.init(asset: AVAsset(url: URL(string: "http://clappr.sample/master.m3u8")!), automaticallyLoadedAssetKeys: nil)
    }

    override func accessLog() -> AVPlayerItemAccessLog? { itemAccessLog }
}
