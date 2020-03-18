import AVFoundation

class PlayerItemMock: AVPlayerItem {
    private var itemAccessLog: AVPlayerItemAccessLog
    private var isFinished: Bool
    private var durationMocked: CMTime
    private var currentTimeMocked: CMTime
    
    override var duration: CMTime { durationMocked }
    
    init(accessLogEvent: AccessLogEventMock, isFinished: Bool = false) {
        self.itemAccessLog = PlayerItemAccessLogMock(accessLogEvent: accessLogEvent)
        self.isFinished = isFinished
        self.durationMocked = CMTimeMakeWithSeconds(100, preferredTimescale: Int32(NSEC_PER_SEC))
        self.currentTimeMocked = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
        
        super.init(asset: AVAsset(url: URL(string: "http://clappr.sample/master.m3u8")!), automaticallyLoadedAssetKeys: nil)
    }
    
    override func currentTime() -> CMTime { isFinished ? duration : currentTimeMocked }
    override func accessLog() -> AVPlayerItemAccessLog? { itemAccessLog }
}
