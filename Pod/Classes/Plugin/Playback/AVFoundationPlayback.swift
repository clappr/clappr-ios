import AVFoundation

enum PlaybackState {
    case Idle, Paused, Playing, Buffering
}

public class AVFoundationPlayback: Playback {
    private var kvoStatusDidChangeContext = 0
    private var kvoTimeRangesContext = 0
    private var kvoBufferingContext = 0
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var currentState = PlaybackState.Idle
    
    public var url: NSURL?
    
    public override var pluginName: String {
        return "AVPlayback"
    }

    public override var selectedSubtitle: AVMediaSelectionOption? {
        get {
            return getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristicLegible)
        }
        set {
            setMediaSelectionOption(newValue, characteristic: AVMediaCharacteristicLegible)
        }
    }

    public override var selectedAudioSource: AVMediaSelectionOption? {
        get {
            return getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristicAudible)
        }
        set {
            setMediaSelectionOption(newValue, characteristic: AVMediaCharacteristicAudible)
        }
    }

    public override var subtitles: [AVMediaSelectionOption]? {
        return mediaSelectionGroup(AVMediaCharacteristicLegible)?.options
    }

    public override var audioSources: [AVMediaSelectionOption]? {
        return mediaSelectionGroup(AVMediaCharacteristicAudible)?.options
    }
    
    public override class func canPlay(options: Options) -> Bool {
        guard let urlString = options[kSourceUrl] as? String, let _ = NSURL(string: urlString) else {
            return false
        }
        
        return true
    }
    
    public required init(options: Options) {
        if let urlString = options[kSourceUrl] as? String {
            self.url = NSURL(string: urlString)
        }
        
        super.init(options: options)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        super.init()
    }
    
    public override func layoutSubviews() {
        if let playerLayer = playerLayer {
            playerLayer.frame = self.bounds
        }
    }
    
    public override func play() {
        if player == nil {
            setupPlayer()
        }
        
        player?.play()
        
        if let currentItem = player?.currentItem {
            if !currentItem.playbackLikelyToKeepUp {
                updateState(.Buffering)
            }
        }
    }
    
    private func setupPlayer() {
        if let url = self.url {
            player = AVPlayer(URL: url)
            playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer!)
            addObservers()
        } else {
            trigger(.Error)
        }
    }
    
    private func addObservers() {
        player?.addObserver(self, forKeyPath: "currentItem.status",
                            options: .New, context: &kvoStatusDidChangeContext)
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges",
                            options: .New, context: &kvoTimeRangesContext)
        player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                            options: .New, context: &kvoBufferingContext)
        player?.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty",
                            options: .New, context: &kvoBufferingContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AVFoundationPlayback.playbackDidEnd),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
    }
    
    func playbackDidEnd() {
        trigger(.Ended)
        updateState(.Idle)
        player?.seekToTime(kCMTimeZero)
    }
    
    public override func pause() {
        player?.pause()
        updateState(.Paused)
    }
    
    public override func stop() {
        player?.pause()
        playbackDidEnd()
        removeObservers()
        playerLayer?.removeFromSuperlayer()
        player = nil
    }
    
    public override func isPlaying() -> Bool {
        return player != nil && player?.rate > 0
    }
    
    public override func seekTo(timeInterval: NSTimeInterval) {
        let time = CMTimeMakeWithSeconds(timeInterval, Int32(NSEC_PER_SEC))
        
        player?.currentItem?.seekToTime(time)
        trigger(.TimeUpdated, userInfo: ["position" : CMTimeGetSeconds(time)])
    }
    
    public override func duration() -> Double {
        guard playbackType() == .VOD, let item = player?.currentItem else {
            return 0
        }
        
        return CMTimeGetSeconds(item.asset.duration)
    }
    
    public override func playbackType() -> PlaybackType {
        guard let player = player, let duration = player.currentItem?.asset.duration else {
            return .Unknown
        }
        
        return duration == kCMTimeIndefinite ? .Live : .VOD
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
        let previousState = currentState
        currentState = newState
        
        switch newState {
        case .Buffering:
            trigger(.Buffering)
        case .Paused:
            trigger(.Pause)
        case .Playing:
            if previousState == .Buffering {
                trigger(.BufferFull)
            }
            trigger(.Play)
        default:
            break
        }
    }
    
    private func handleStatusChangedEvent() {
        if player?.status == .ReadyToPlay {
            readyToPlay()
        } else if player?.status == .Failed {
            self.trigger(.Error, userInfo: ["error": player!.currentItem!.error!])
        }
    }
    
    private func readyToPlay() {
        trigger(.Ready)
        
        if let subtitles = self.subtitles {
            trigger(.SubtitleSourcesUpdated, userInfo: ["subtitles" : subtitles])
        }
        
        if let audioSources = self.audioSources {
            trigger(.AudioSourcesUpdated, userInfo: ["audios" : audioSources])
        }
        
        addTimeElapsedCallback()
    }
    
    private func addTimeElapsedCallback() {
        player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.2, 600), queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }
    
    private func timeUpdated(time: CMTime) {
        if isPlaying() {
            updateState(.Playing)
            trigger(.TimeUpdated, userInfo: ["position" : CMTimeGetSeconds(time)])
        }
    }
    
    private func handleTimeRangesEvent() {
        guard let timeRange = player?.currentItem?.loadedTimeRanges.first?.CMTimeRangeValue else {
            return
        }
        
        let info = ["start_position" : CMTimeGetSeconds(timeRange.start),
                      "end_position" : CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)),
                          "duration" : CMTimeGetSeconds(timeRange.start)]
        
        trigger(.Progress, userInfo: info)
    }
    
    private func handleBufferingEvent(keyPath: String) {
        if keyPath == "currentItem.playbackLikelyToKeepUp" {
            if player?.currentItem!.playbackLikelyToKeepUp == false {
                updateState(.Buffering)
            } else if currentState == .Buffering {
                play()
            }
        } else if keyPath == "currentItem.playbackBufferEmpty" {
            updateState(.Buffering)
        }
    }
    
    private func setMediaSelectionOption(option: AVMediaSelectionOption?, characteristic: String) {
        if let group = mediaSelectionGroup(characteristic) {
            player?.currentItem?.selectMediaOption(option, inMediaSelectionGroup: group)
        }
    }

    private func getSelectedMediaOptionWithCharacteristic(characteristic: String) -> AVMediaSelectionOption? {
        if let group = mediaSelectionGroup(characteristic) {
            return player?.currentItem?.selectedMediaOptionInMediaSelectionGroup(group)
        }
        return nil
    }
    
    private func mediaSelectionGroup(characteristic: String) -> AVMediaSelectionGroup? {
        return player?.currentItem?.asset.mediaSelectionGroupForMediaCharacteristic(characteristic)
    }
    
    deinit {
        removeObservers()
    }
    
    private func removeObservers() {
        if player != nil {
            player?.removeObserver(self, forKeyPath: "currentItem.status")
            player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackBufferEmpty")
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}