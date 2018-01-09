import AVFoundation
import AVKit

enum PlaybackState {
    case idle, paused, playing, buffering
}

open class AVFoundationPlayback: Playback, AVPlayerViewControllerDelegate {
    fileprivate static let mimeTypes = [
        "mp4": "video/mp4",
        "m3u8": "application/x-mpegurl",
        ]

    fileprivate var kvoStatusDidChangeContext = 0
    fileprivate var kvoTimeRangesContext = 0
    fileprivate var kvoBufferingContext = 0
    fileprivate var kvoExternalPlaybackActiveContext = 0
    fileprivate var kvoPlayerRateContext = 0

    dynamic internal var player: AVPlayer?

    lazy var nowPlayingService: AVFoundationNowPlayingService = {
        return AVFoundationNowPlayingService()
    }()

    fileprivate var playerLooper: AVPlayerLooper?
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var playerStatus: AVPlayerItemStatus = .unknown
    fileprivate var currentState = PlaybackState.idle
    fileprivate var timeObserver: Any?
    fileprivate var asset: AVURLAsset?

    private var backgroundSessionBackup: String?

    open var url: URL? {
        return asset?.url
    }

    open override var pluginName: String {
        return "AVPlayback"
    }

    open override var selectedSubtitle: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristicLegible)
            return MediaOptionFactory.fromAVMediaOption(option, type: .subtitle) ?? MediaOptionFactory.offSubtitle()
        }
        set {
            let newOption = newValue?.raw as? AVMediaSelectionOption
            setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristicLegible)
        }
    }

    open override var selectedAudioSource: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristicAudible)
            return MediaOptionFactory.fromAVMediaOption(option, type: .audioSource)
        }
        set {
            if let newOption = newValue?.raw as? AVMediaSelectionOption {
                setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristicAudible)
            }
        }
    }

    open override var subtitles: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristicLegible) else {
            return []
        }

        let availableOptions = mediaGroup.options.flatMap({ MediaOptionFactory.fromAVMediaOption($0, type: .subtitle) })
        return availableOptions + [MediaOptionFactory.offSubtitle()]
    }

    open override var audioSources: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristicAudible) else {
            return []
        }
        return mediaGroup.options.flatMap({ MediaOptionFactory.fromAVMediaOption($0, type: .audioSource) })
    }

    open override var isPlaying: Bool {
        if let concretePlayer = player {
            return concretePlayer.rate > 0
        }

        return false
    }

    open override var isPaused: Bool {
        return currentState == .paused
    }

    open override var isBuffering: Bool {
        return currentState == .buffering
    }

    open override var duration: Double {
        guard playbackType == .vod, let item = player?.currentItem else {
            return 0
        }
        return CMTimeGetSeconds(item.asset.duration)
    }

    open override var position: Double {
        guard playbackType == .vod, let player = self.player else {
            return 0
        }
        return CMTimeGetSeconds(player.currentTime())
    }

    open override var playbackType: PlaybackType {
        guard let player = player, let duration = player.currentItem?.asset.duration else {
            return .unknown
        }

        return duration == kCMTimeIndefinite ? .live : .vod
    }

    open override class func canPlay(_ options: Options) -> Bool {
        var mimeType = ""

        if let urlString = options[kSourceUrl] as? String,
            let url = URL(string: urlString),
            let mimeTypeFromPath = mimeTypes[url.pathExtension] {
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
            if let url = URL(string: urlString) {
                asset = AVURLAsset(url: url)
            }
        }
    }

    public func setDelegate(_ delegate: AVAssetResourceLoaderDelegate) {
        self.asset?.resourceLoader.setDelegate(delegate, queue: DispatchQueue(label: "\(String(describing: asset?.url))-delegateQueue"))
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init() {
        super.init()
    }

    public required init(context _: UIBaseObject) {
        fatalError("init(context:) has not been implemented")
    }

    open override func layoutSubviews() {
        if let playerLayer = playerLayer {
            playerLayer.frame = self.bounds
        }
    }

    open override func play() {
        if player == nil {
            setupPlayer()
        }

        trigger(.willPlay)
        player?.play()

        if let currentItem = player?.currentItem {
            if !currentItem.isPlaybackLikelyToKeepUp {
                updateState(.buffering)
            }
        }
    }

    fileprivate func setupPlayer() {
        if let asset = self.asset {
            let item: AVPlayerItem = AVPlayerItem(asset: asset)
            if options[kLoop] as? Bool ?? false {
                player = AVQueuePlayer()
                if let queuePlayer = player as? AVQueuePlayer {
                    playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
                }
            } else {
                player = AVPlayer(playerItem: item)
            }
            player?.allowsExternalPlayback = true
            playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer!)
            addObservers()
        } else {
            trigger(.error)
            Logger.logError("could not setup player", scope: pluginName)
        }
    }

    fileprivate func loadMetadata() {
        if let playerItem = player?.currentItem {
            nowPlayingService.setItems(to: playerItem, with: options)
        }
    }

    fileprivate func addObservers() {
        player?.addObserver(self, forKeyPath: "currentItem.status",
                            options: .new, context: &kvoStatusDidChangeContext)
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges",
                            options: .new, context: &kvoTimeRangesContext)
        player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
                            options: .new, context: &kvoBufferingContext)
        player?.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty",
                            options: .new, context: &kvoBufferingContext)
        player?.addObserver(self, forKeyPath: "externalPlaybackActive",
                            options: .new, context: &kvoExternalPlaybackActiveContext)
        player?.addObserver(self, forKeyPath: "rate",
                            options: .new, context: &kvoPlayerRateContext)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(AVFoundationPlayback.playbackDidEnd),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)
    }

    func playbackDidEnd(notification: NSNotification) {
        if let object = notification.object as? AVPlayerItem, let item = self.player?.currentItem {
            if object == item {
                let duration = item.duration
                let position = item.currentTime()
                if fabs(CMTimeGetSeconds(duration) - CMTimeGetSeconds(position)) <= 2.0 {
                    trigger(.didComplete)
                    updateState(.idle)
                }
            }
        }
    }

    open override func pause() {
        trigger(.willPause)
        player?.pause()
        updateState(.paused)
    }

    open override func stop() {
        trigger(.willStop)
        updateState(.idle)
        player?.pause()
        releaseResources()
        trigger(.didStop)
    }

    func releaseResources() {
        removeObservers()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
    }

    open override func seek(_ timeInterval: TimeInterval) {
        let time = CMTimeMakeWithSeconds(timeInterval, Int32(NSEC_PER_SEC))

        player?.currentItem?.seek(to: time)
        trigger(.seek)
        trigger(.positionUpdate, userInfo: ["position": CMTimeGetSeconds(time)])
    }

    public func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        trigger(.seek)
    }

    open override func mute(_ enabled: Bool) {
        if enabled {
            player?.volume = 0.0
        } else {
            player?.volume = 1.0
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of _: Any?,
                                    change _: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        guard let concreteContext = context else {
            return
        }

        switch concreteContext {
        case &kvoStatusDidChangeContext:
            handleStatusChangedEvent()
        case &kvoTimeRangesContext:
            handleTimeRangesEvent()
        case &kvoBufferingContext:
            handleBufferingEvent(keyPath)
        case &kvoExternalPlaybackActiveContext:
            handleExternalPlaybackActiveEvent()
        case &kvoPlayerRateContext:
            handlePlayerRateChanged()
        default:
            break
        }
    }

    fileprivate func updateState(_ newState: PlaybackState) {
        guard currentState != newState else { return }
        currentState = newState

        switch newState {
        case .buffering:
            trigger(.stalled)
        case .paused:
            trigger(.didPause)
        case .playing:
            trigger(.playing)
        default:
            break
        }
    }

    fileprivate func handleExternalPlaybackActiveEvent() {
        guard let concretePlayer = player else {
            return
        }

        if concretePlayer.isExternalPlaybackActive {
            enableBackgroundSession()
        } else {
            restoreBackgroundSession()
        }

        self.trigger(.airPlayStatusUpdate, userInfo: ["externalPlaybackActive": player!.isExternalPlaybackActive])
    }

    private func enableBackgroundSession() {
        backgroundSessionBackup = AVAudioSession.sharedInstance().category
        changeBackgroundSession(to: AVAudioSessionCategoryPlayback)
    }

    private func restoreBackgroundSession() {
        if let concreteBackgroundSession = backgroundSessionBackup {
            changeBackgroundSession(to: concreteBackgroundSession)
        }
    }

    private func changeBackgroundSession(to category: String) {
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(category, with: .allowAirPlay)
            } else {
                try AVAudioSession.sharedInstance().setCategory(category)
            }
        } catch {
            Logger.logError("It was not possible to set the audio session category", scope: pluginName)
        }
    }

    fileprivate func handleStatusChangedEvent() {
        guard let player = player, let currentItem = player.currentItem, playerStatus != currentItem.status else { return }
        playerStatus = currentItem.status

        if playerStatus == .readyToPlay && currentState != .paused {
            readyToPlay()
        } else if playerStatus == .failed {
            let error = player.currentItem!.error!
            self.trigger(.error, userInfo: ["error": error])
            Logger.logError("playback failed with error: \(error.localizedDescription) ", scope: pluginName)
        }
    }

    fileprivate func readyToPlay() {
        trigger(.ready)

        if let subtitles = self.subtitles {
            trigger(.didUpdateSubtitleSource, userInfo: ["subtitles": subtitles])
        }

        if let audioSources = self.audioSources {
            trigger(.didUpdateAudioSource, userInfo: ["audios": audioSources])
        }

        loadMetadata()

        addTimeElapsedCallback()
    }

    fileprivate func addTimeElapsedCallback() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.2, 600), queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }

    fileprivate func timeUpdated(_ time: CMTime) {
        if isPlaying {
            updateState(.playing)
            trigger(.positionUpdate, userInfo: ["position": CMTimeGetSeconds(time)])
        }
    }

    fileprivate func handleTimeRangesEvent() {
        guard let timeRange = player?.currentItem?.loadedTimeRanges.first?.timeRangeValue else {
            return
        }

        let info = [
            "start_position": CMTimeGetSeconds(timeRange.start),
            "end_position": CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)),
            "duration": CMTimeGetSeconds(timeRange.start),
            ]

        trigger(.bufferUpdate, userInfo: info)
    }

    fileprivate func handleBufferingEvent(_ keyPath: String?) {
        guard let keyPath = keyPath, currentState != .paused else {
            return
        }

        if keyPath == "currentItem.playbackLikelyToKeepUp" {
            if player?.currentItem?.isPlaybackLikelyToKeepUp == true && currentState == .buffering {
                play()
            } else {
                updateState(.buffering)
            }
        } else if keyPath == "currentItem.playbackBufferEmpty" {
            updateState(.buffering)
        }
    }

    fileprivate func handlePlayerRateChanged() {
        if player?.rate == 0 && playerStatus != .unknown && currentState != .idle {
            updateState(.paused)
        }
    }

    fileprivate func setMediaSelectionOption(_ option: AVMediaSelectionOption?, characteristic: String) {
        if let group = mediaSelectionGroup(characteristic) {
            player?.currentItem?.select(option, in: group)
        }
    }

    fileprivate func getSelectedMediaOptionWithCharacteristic(_ characteristic: String) -> AVMediaSelectionOption? {
        if let group = mediaSelectionGroup(characteristic) {
            return player?.currentItem?.selectedMediaOption(in: group)
        }
        return nil
    }

    fileprivate func mediaSelectionGroup(_ characteristic: String) -> AVMediaSelectionGroup? {
        return player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: characteristic)
    }

    deinit {
        removeObservers()
    }

    fileprivate func removeObservers() {
        if player != nil {
            player?.removeObserver(self, forKeyPath: "currentItem.status")
            player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackBufferEmpty")
            player?.removeObserver(self, forKeyPath: "externalPlaybackActive")
            player?.removeObserver(self, forKeyPath: "rate")

            if let timeObserver = self.timeObserver {
                player?.removeTimeObserver(observer: timeObserver)
            }
        }

        NotificationCenter.default.removeObserver(self)
    }

    override open func destroy() {
        super.destroy()
        Logger.logDebug("destroying", scope: "AVFoundationPlayback")
        releaseResources()
        Logger.logDebug("destroyed", scope: "AVFoundationPlayback")
    }
}
