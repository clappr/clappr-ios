import AVFoundation

class PlayerItemMock: AVPlayerItem {
    private var itemAccessLog: AVPlayerItemAccessLog
    private var isFinished: Bool
    private var _duration: CMTime
    private var _currentTime: CMTime
    
    override var duration: CMTime { _duration }
    
    init(accessLogEvent: AccessLogEventMock, isFinished: Bool = false) {
        self.itemAccessLog = PlayerItemAccessLogMock(accessLogEvent: accessLogEvent)
        self.isFinished = isFinished
        self._duration = CMTimeMakeWithSeconds(100, preferredTimescale: Int32(NSEC_PER_SEC))
        self._currentTime = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
        
        super.init(asset: AVAsset(url: URL(string: "http://clappr.sample/master.m3u8")!), automaticallyLoadedAssetKeys: nil)
    }
    
    override func currentTime() -> CMTime { isFinished ? duration : _currentTime }
    override func accessLog() -> AVPlayerItemAccessLog? { itemAccessLog }
}
