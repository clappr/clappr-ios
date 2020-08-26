import AVFoundation

@testable import Clappr

class PlayerItemMock: AVPlayerItem {
    private var itemAccessLog: AVPlayerItemAccessLog
    private var isFinished: Bool
    private var durationMocked: CMTime
    private var currentTimeMocked: CMTime
    private var assetMocked: AVAssetMock

    var mediaSelectionOptionMocked: AVMediaSelectionOption?

    override var asset: AVAsset { assetMocked }
    override var duration: CMTime { durationMocked }
    
    init(accessLogEvent: AccessLogEventMock, isFinished: Bool = false) {
        self.itemAccessLog = PlayerItemAccessLogMock(accessLogEvent: accessLogEvent)
        self.isFinished = isFinished
        self.durationMocked = CMTimeMakeWithSeconds(100, preferredTimescale: Int32(NSEC_PER_SEC))
        self.currentTimeMocked = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
        self.assetMocked = AVAssetMock()

        super.init(asset: AVAsset(url: URL(string: "http://clappr.sample/master.m3u8")!), automaticallyLoadedAssetKeys: nil)
    }
    
    override func currentTime() -> CMTime { isFinished ? duration : currentTimeMocked }
    override func accessLog() -> AVPlayerItemAccessLog? { itemAccessLog }

    override func select(_ mediaSelectionOption: AVMediaSelectionOption?, in mediaSelectionGroup: AVMediaSelectionGroup) {
        mediaSelectionOptionMocked = MediaOption.mockedSubtitle.avMediaSelectionOption
    }
}

class AVAssetMock: AVAsset {
    override func mediaSelectionGroup(forMediaCharacteristic mediaCharacteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? { AVMediaSelectionGroup() }
}

extension MediaOption {
    static var mockedSubtitle = MediaOption(name: "Mocked", type: .subtitle, language: "moc", raw: AVMediaSelectionOption())
}
