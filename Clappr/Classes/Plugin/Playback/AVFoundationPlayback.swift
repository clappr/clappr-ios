import AVFoundation

enum PlaybackState {
    case Idle, Paused, Playing, Buffering
}

public class AVFoundationPlayback: Playback {
    private static let mimeTypes = ["mp4" : "video/mp4",
                                   "m3u8" : "application/x-mpegurl"]
    
    private var kvoStatusDidChangeContext = 0
    private var kvoTimeRangesContext = 0
    private var kvoBufferingContext = 0
    private var kvoExternalPlaybackActiveContext = 0
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var currentState = PlaybackState.Idle
    
    public var url: NSURL?
    
    public override var pluginName: String {
        return "AVPlayback"
    }
    
    public override var selectedSubtitle: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristicLegible)
            return MediaOptionFactory.fromAVMediaOption(option, type: .Subtitle) ?? MediaOptionFactory.offSubtitle()
        }
        set {
            let newOption = newValue?.raw as? AVMediaSelectionOption
            setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristicLegible)
        }
    }
    
    public override var selectedAudioSource: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristicAudible)
            return MediaOptionFactory.fromAVMediaOption(option, type: .AudioSource)
        }
        set {
            if let newOption = newValue?.raw as? AVMediaSelectionOption {
                setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristicAudible)
            }
        }
    }
    
    public override var subtitles: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristicLegible) else {
            return []
        }
        let availableOptions = mediaGroup.options.flatMap({MediaOptionFactory.fromAVMediaOption($0, type: .Subtitle)})
        return availableOptions + [MediaOptionFactory.offSubtitle()]
    }
    
    public override var audioSources: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristicAudible) else {
            return []
        }
        return mediaGroup.options.flatMap({MediaOptionFactory.fromAVMediaOption($0, type: .AudioSource)})
    }

    public override var isPlaying: Bool {
        return player != nil && player?.rate > 0
    }

    public override var isPaused: Bool {
        return currentState == .Paused
    }

    public override var isBuffering: Bool {
        return currentState == .Buffering
    }

    public override var duration: Double {
        guard playbackType == .VOD, let item = player?.currentItem else {
            return 0
        }
        return CMTimeGetSeconds(item.asset.duration)
    }

    public override var position: Double {
        guard playbackType == .VOD, let player = self.player else {
            return 0
        }
        return CMTimeGetSeconds(player.currentTime())
    }

    public override var playbackType: PlaybackType {
        guard let player = player, let duration = player.currentItem?.asset.duration else {
            return .Unknown
        }

        return duration == kCMTimeIndefinite ? .Live : .VOD
    }

    public override class func canPlay(options: Options) -> Bool {
        var mimeType = ""
        
        if let urlString = options[kSourceUrl] as? String,
            let url = NSURL(string: urlString),
            let pathExtension = url.pathExtension,
            let mimeTypeFromPath = mimeTypes[pathExtension] {
            mimeType = mimeTypeFromPath
        }
        
        if let mimeTypeFromParameter = options[kMimeType] as? String {
            mimeType = mimeTypeFromParameter
        }
        
        return AVURLAsset.isPlayableExtendedMIMEType(mimeType)
    }
    
    public required init(options: Options) {
        super.init(options: options)
        
        if let urlString = options[kSourceUrl] as? String {
            url = NSURL(string: urlString)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public required init() {
        super.init()
    }
    
    public required init(context: UIBaseObject) {
        fatalError("init(context:) has not been implemented")
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
            player?.allowsExternalPlayback = true
            player?.externalPlaybackActive
            playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer!)
            addObservers()
        } else {
            trigger(.Error)
            Logger.logError("could not setup player", scope: pluginName)
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
        player?.addObserver(self, forKeyPath: "externalPlaybackActive",
                            options: .New, context: &kvoExternalPlaybackActiveContext)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AVFoundationPlayback.playbackDidEnd),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
    }
    
    func playbackDidEnd() {
        trigger(.Ended)
        updateState(.Idle)
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
        playerLayer = nil
        player = nil
    }
    
    public override func seek(timeInterval: NSTimeInterval) {
        let time = CMTimeMakeWithSeconds(timeInterval, Int32(NSEC_PER_SEC))
        
        player?.currentItem?.seekToTime(time)
        trigger(.TimeUpdated, userInfo: ["position" : CMTimeGetSeconds(time)])
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                                change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch context {
        case &kvoStatusDidChangeContext:
            handleStatusChangedEvent()
        case &kvoTimeRangesContext:
            handleTimeRangesEvent()
        case &kvoBufferingContext:
            handleBufferingEvent(keyPath)
        case &kvoExternalPlaybackActiveContext:
            handleExternalPlaybackActiveEvent()
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

    private func handleExternalPlaybackActiveEvent() {
        self.trigger(.ExternalPlaybackActiveUpdated, userInfo: ["externalPlaybackActive": player!.externalPlaybackActive])
    }
    
    private func handleStatusChangedEvent() {
        if player?.status == .ReadyToPlay {
            readyToPlay()
        } else if player?.status == .Failed {
            let error = player!.currentItem!.error!
            self.trigger(.Error, userInfo: ["error": error])
            Logger.logError("playback failed with error: \(error.localizedDescription) ", scope: pluginName)
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
        if isPlaying {
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
    
    private func handleBufferingEvent(keyPath: String?) {
        guard let keyPath = keyPath where currentState != .Paused else {
            return
        }

        if keyPath == "currentItem.playbackLikelyToKeepUp" {
            if player?.currentItem?.playbackLikelyToKeepUp == true && currentState == .Buffering  {
                play()
            } else {
                updateState(.Buffering)
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
            player?.removeObserver(self, forKeyPath: "externalPlaybackActive")
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
