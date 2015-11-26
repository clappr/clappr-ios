import AVFoundation

public class AVFoundationPlayback: Playback {
    private var kvoStatusDidChangeContext = 0
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }
    
    public required init(url: NSURL) {
        super.init(url: url)
        setupPlayer()
        addKeyValueObservers()
    }
    
    private func setupPlayer() {
        player = AVPlayer(URL: url)
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer)
    }
    
    private func addKeyValueObservers() {
        player.addObserver(self, forKeyPath: "currentItem.status",
            options: .New, context: &kvoStatusDidChangeContext)
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
                if player.status == .ReadyToPlay {
                    self.trigger(.Ready)
                } else if player.status == .Failed {
                    self.trigger(.Error, userInfo: ["error": player.currentItem!.error!])
                }
                
            default:
                break
            }
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "currentItem.status")
    }
}