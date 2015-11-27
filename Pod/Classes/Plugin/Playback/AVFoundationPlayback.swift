import AVFoundation

public class AVFoundationPlayback: Playback {
    private var kvoStatusDidChangeContext = 0
    private var kvoTimeRangesContext = 0
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }
    
    public required init(url: NSURL) {
        super.init(url: url)
        setupPlayer()
        addKeyValueObservers()
        addTimeElapsedCallback()
    }
    
    private func setupPlayer() {
        player = AVPlayer(URL: url)
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer)
    }
    
    private func addKeyValueObservers() {
        player.addObserver(self, forKeyPath: "currentItem.status",
            options: .New, context: &kvoStatusDidChangeContext)
        player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges",
            options: .New, context: &kvoTimeRangesContext)
    }
    
    private func addTimeElapsedCallback() {
        player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.5, 600), queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }
    
    private func timeUpdated(time: CMTime) {
        if isPlaying() {
            trigger(.TimeUpdated, userInfo: ["position" : CMTimeGetSeconds(time)])
        }
    }
    
    public override func layoutSubviews() {
        playerLayer.frame = self.bounds
    }
    
    public override func play() {
        player.play()
    }
    
    public override func pause() {
        player.pause()
    }
    
    public override func isPlaying() -> Bool {
        return player.rate > 0
    }
    
    public override func seekTo(timeInterval: NSTimeInterval) {
        let time = CMTimeMakeWithSeconds(timeInterval, Int32(NSEC_PER_SEC))
        
        player.currentItem?.seekToTime(time)
        trigger(.TimeUpdated, userInfo: ["position" : CMTimeGetSeconds(time)])
    }
    
    public override func duration() -> Double {
        guard player.status == .ReadyToPlay, let item = player.currentItem else {
            return 0
        }
        
        return CMTimeGetSeconds(item.asset.duration)
    }
    
    public override class func canPlay(url: NSURL) -> Bool {
        return true
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            switch context {
            case &kvoStatusDidChangeContext:
                handleStatusChangedEvent()
            case &kvoTimeRangesContext:
                handleTimeRangesEvent()
            default:
                break
            }
    }
    
    private func handleStatusChangedEvent() {
        if player.status == .ReadyToPlay {
            self.trigger(.Ready)
        } else if player.status == .Failed {
            self.trigger(.Error, userInfo: ["error": player.currentItem!.error!])
        }
    }
    
    private func handleTimeRangesEvent() {
        guard let timeRange = player.currentItem?.loadedTimeRanges.first?.CMTimeRangeValue else {
            return
        }
        
        let info = ["start_position" : CMTimeGetSeconds(timeRange.start),
                      "end_position" : CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)),
                          "duration" : CMTimeGetSeconds(timeRange.start)]
        
        trigger(.Progress, userInfo: info)
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "currentItem.status")
        player.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
    }
}