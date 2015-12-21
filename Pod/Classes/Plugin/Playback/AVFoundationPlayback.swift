import AVFoundation

enum PlaybackState {
    case Idle, Paused, Playing, Buffering
}

public class AVFoundationPlayback: Playback {
    private var kvoStatusDidChangeContext = 0
    private var kvoTimeRangesContext = 0
    private var kvoBufferingContext = 0
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var currentState = PlaybackState.Idle
    
    private func setupPlayer() {
        player = AVPlayer(URL: url)
        playerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer)
        addObservers()
        addTimeElapsedCallback()
    }
    
    private func addObservers() {
        player.addObserver(self, forKeyPath: "currentItem.status",
            options: .New, context: &kvoStatusDidChangeContext)
        player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges",
            options: .New, context: &kvoTimeRangesContext)
        player.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
            options: .New, context: &kvoBufferingContext)
        player.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty",
            options: .New, context: &kvoBufferingContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackDidEnd",
            name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    }
    
    func playbackDidEnd() {
        trigger(.Ended)
        updateState(.Idle)
        player.seekToTime(kCMTimeZero)
    }
    
    private func addTimeElapsedCallback() {
        player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.2, 600), queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }
    
    private func timeUpdated(time: CMTime) {
        if isPlaying() {
            updateState(.Playing)
            trigger(.TimeUpdated, userInfo: ["position" : CMTimeGetSeconds(time)])
        }
    }
    
    public override func layoutSubviews() {
        if playerLayer != nil {
            playerLayer.frame = self.bounds
        }
    }
    
    public override func play() {
        if player == nil {
            setupPlayer()
        }
        
        player.play()
        
        if !player.currentItem!.playbackLikelyToKeepUp {
            updateState(.Buffering)
        }
    }
    
    public override func pause() {
        player.pause()
        updateState(.Paused)
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
            case &kvoBufferingContext:
                handleBufferingEvent(keyPath!)
            default:
                break
            }
    }
    
    private func updateState(newState: PlaybackState) {
        guard currentState != newState else { return }
        
        currentState = newState
        
        switch newState {
        case .Buffering:
            trigger(.Buffering)
        case .Paused:
            trigger(.Pause)
        case .Playing:
            trigger(.Play)
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
    
    private func handleBufferingEvent(keyPath: String) {
        if keyPath == "currentItem.playbackLikelyToKeepUp" {
            if player.currentItem!.playbackLikelyToKeepUp == false {
                updateState(.Buffering)
            } else if currentState == .Buffering {
                play()
            }
        } else if keyPath == "currentItem.playbackBufferEmpty" {
            updateState(.Buffering)
        }
    }
    
    deinit {
        if player != nil {
            player.removeObserver(self, forKeyPath: "currentItem.status")
            player.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            player.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
            player.removeObserver(self, forKeyPath: "currentItem.playbackBufferEmpty")
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}