import AVFoundation

public class AVFoundationPlayback: Playback {
    private var avPlayer: AVPlayer!
    private var avPlayerLayer: AVPlayerLayer!
    
    public required init(url: NSURL) {
        super.init(url: url)
        setupPlayer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }
    
    private func setupPlayer() {
        avPlayer = AVPlayer(URL: url)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        self.layer.addSublayer(avPlayerLayer)
    }
    
    public override func play() {
        avPlayer.play()
    }
    
    public override func layoutSubviews() {
        avPlayerLayer.frame = self.bounds
    }
    
    public override func pause() {
        avPlayer.pause()
    }
    
    public override class func canPlay(url: NSURL) -> Bool {
        return true
    }
}