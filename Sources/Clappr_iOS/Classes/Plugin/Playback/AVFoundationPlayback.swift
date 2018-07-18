import AVFoundation

enum PlaybackState {
    case idle, paused, playing, buffering
}

open class AVFoundationPlayback: Playback {
    fileprivate static let mimeTypes = [
        "mp4": "video/mp4",
        "m3u8": "application/x-mpegurl",
        ]

    fileprivate var kvoStatusDidChangeContext = 0
    fileprivate var kvoLoadedTimeRangesContext = 0
    fileprivate var kvoSeekableTimeRangesContext = 0
    fileprivate var kvoBufferingContext = 0
    fileprivate var kvoExternalPlaybackActiveContext = 0
    fileprivate var kvoPlayerRateContext = 0

    private(set) var seekToTimeWhenReadyToPlay: TimeInterval?

    @objc internal dynamic var player: AVPlayer?
    fileprivate var playerLayer: AVPlayerLayer?
    fileprivate var playerStatus: AVPlayerItemStatus = .unknown
    fileprivate var currentState = PlaybackState.idle {
        didSet {
            switch currentState {
            case .buffering:
                accessibilityIdentifier = "AVFoundationPlaybackBuffering"
            case .paused:
                accessibilityIdentifier = "AVFoundationPlaybackPaused"
            case .playing:
                accessibilityIdentifier = "AVFoundationPlaybackPlaying"
            case .idle:
                accessibilityIdentifier = "AVFoundationPlaybackIdle"
            }
        }
    }
    fileprivate var timeObserver: Any?
    fileprivate var asset: AVURLAsset?

    private var backgroundSessionBackup: String?

    @objc open var url: URL? {
        return asset?.url
    }

    open override var pluginName: String {
        return "AVPlayback"
    }

    open override var selectedSubtitle: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristic.legible.rawValue)
            return MediaOptionFactory.fromAVMediaOption(option, type: .subtitle) ?? MediaOptionFactory.offSubtitle()
        }
        set {
            let newOption = newValue?.raw as? AVMediaSelectionOption
            setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristic.legible.rawValue)
        }
    }

    open override var selectedAudioSource: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristic.audible.rawValue)
            return MediaOptionFactory.fromAVMediaOption(option, type: .audioSource)
        }
        set {
            if let newOption = newValue?.raw as? AVMediaSelectionOption {
                setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristic.audible.rawValue)
            }
        }
    }

    open override var subtitles: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristic.legible.rawValue) else {
            return []
        }

        let availableOptions = mediaGroup.options.flatMap({ MediaOptionFactory.fromAVMediaOption($0, type: .subtitle) })
        return availableOptions + [MediaOptionFactory.offSubtitle()]
    }

    open override var audioSources: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristic.audible.rawValue) else {
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

    open override var bounds: CGRect {
        didSet {
            setupMaxResolution(for: bounds.size)
        }
    }

    open override var duration: Double {
        guard let item = player?.currentItem else {
            return 0
        }

        if playbackType == .vod {
            return CMTimeGetSeconds(item.asset.duration)
        }

        if playbackType == .live {
            if supportDVR, let duration = seekableTimeRanges.first?.timeRangeValue.duration.seconds {
                return duration
            } else {
                return 0
            }
        }

        return 0
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
        self.asset = createAsset(from: options[kSourceUrl] as? String)
    }

    private func createAsset(from sourceUrl: String?) -> AVURLAsset? {
        guard let urlString = sourceUrl, let url = URL(string: urlString) else {
            return nil
        }

        return AVURLAssetWithCookiesBuilder(url: url).asset
    }

    @objc public func setDelegate(_ delegate: AVAssetResourceLoaderDelegate) {
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
            player = AVPlayer(playerItem: item)
            player?.allowsExternalPlayback = true
            playerLayer = AVPlayerLayer(player: player)
            layer.addSublayer(playerLayer!)
            setupMaxResolution(for: bounds.size)
            addObservers()
            trigger(.ready)
        } else {
            trigger(.error)
            Logger.logError("could not setup player", scope: pluginName)
        }
    }

    @objc internal func addObservers() {
        player?.addObserver(self, forKeyPath: "currentItem.status",
                            options: .new, context: &kvoStatusDidChangeContext)
        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges",
                            options: .new, context: &kvoLoadedTimeRangesContext)
        player?.addObserver(self, forKeyPath: "currentItem.seekableTimeRanges",
                            options: .new, context: &kvoSeekableTimeRangesContext)
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

    @objc func playbackDidEnd() {
        trigger(.didComplete)
        updateState(.idle)
    }

    open override func pause() {
        trigger(.willPause)
        player?.pause()
        updateState(.paused)
    }

    open override func stop() {
        trigger(.willStop)
        player?.pause()
        updateState(.idle)
        releaseResources()
        trigger(.didStop)
    }

    @objc func releaseResources() {
        removeObservers()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
    }

    @objc var isReadyToSeek: Bool {
        return player?.currentItem?.status == .readyToPlay
    }

    private func getSeekableTimeRange(with timeInterval: TimeInterval) -> CMTimeRange? {
        return seekableTimeRanges.first(where: { $0.timeRangeValue.start.seconds >= timeInterval && timeInterval < $0.timeRangeValue.end.seconds })?.timeRangeValue
    }

    open override func seek(_ timeInterval: TimeInterval) {
        if supportDVR {
            var timeToSeek = timeInterval

            if let seekStartTime = getSeekableTimeRange(with: timeInterval)?.start.seconds {
                timeToSeek = timeToSeek + seekStartTime
            }

            seek(timeToSeek) { [weak self] in
                if let usingDVR = self?.usingDVR {
                    self?.trigger(.usingDVR, userInfo: ["enabled": usingDVR])
                }
            }
        } else {
            seek(timeInterval, nil)
        }
    }

    private func seek(_ timeInterval: TimeInterval, _ triggerEvent: (() -> Void)?) {
        if !isReadyToSeek {
            seekToTimeWhenReadyToPlay = timeInterval
            return
        }

        let time = CMTimeMakeWithSeconds(timeInterval, Int32(NSEC_PER_SEC))

        trigger(.seek)
        trigger(.willSeek)

        player?.currentItem?.seek(to: time) { [weak self] success in
            if success {
                self?.trigger(.didSeek)
                if let triggerEvent = triggerEvent {
                    triggerEvent()
                }
            }
        }

        trigger(.positionUpdate, userInfo: ["position": CMTimeGetSeconds(time)])
    }

    open override func observeValue(forKeyPath keyPath: String?, of _: Any?,
                                    change _: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

        guard let concreteContext = context else {
            return
        }

        switch concreteContext {
        case &kvoStatusDidChangeContext:
            handleStatusChangedEvent()
        case &kvoLoadedTimeRangesContext:
            handleLoadedTimeRangesEvent()
        case &kvoSeekableTimeRangesContext:
            handleSeekableTimeRangesEvent()
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
            print("It was not possible to set the audio session category")
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

    @objc internal func seekOnReadyIfNeeded() {
        if let timeToSeek = seekToTimeWhenReadyToPlay {
            seek(timeToSeek)
            self.seekToTimeWhenReadyToPlay = nil
        }
    }

    fileprivate func readyToPlay() {
        seekOnReadyIfNeeded()

        if let subtitles = self.subtitles {
            trigger(.didUpdateSubtitleSource, userInfo: ["subtitles": subtitles])
        }

        if let audioSources = self.audioSources {
            trigger(.didUpdateAudioSource, userInfo: ["audios": audioSources])
        }

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

    fileprivate func handleLoadedTimeRangesEvent() {
        guard let timeRange = player?.currentItem?.loadedTimeRanges.first?.timeRangeValue else {
            return
        }

        let info = [
            "start_position": CMTimeGetSeconds(timeRange.start),
            "end_position": CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)),
            "duration": CMTimeGetSeconds(timeRange.duration),
            ]

        trigger(.bufferUpdate, userInfo: info)
    }

    fileprivate func handleSeekableTimeRangesEvent() {
        guard !seekableTimeRanges.isEmpty else { return }
        trigger(.seekableUpdate, userInfo: ["seekableTimeRanges": seekableTimeRanges])
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
        if(player?.rate == 0) {
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
        return player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic(rawValue: characteristic))
    }

    deinit {
        removeObservers()
    }

    fileprivate func removeObservers() {
        if player?.observationInfo == nil { return }
        if player != nil {
            player?.removeObserver(self, forKeyPath: "currentItem.status")
            player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges")
            player?.removeObserver(self, forKeyPath: "currentItem.seekableTimeRanges")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
            player?.removeObserver(self, forKeyPath: "currentItem.playbackBufferEmpty")
            player?.removeObserver(self, forKeyPath: "externalPlaybackActive")
            player?.removeObserver(self, forKeyPath: "rate")

            if let timeObserver = self.timeObserver {
                player?.removeTimeObserver(timeObserver)
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

// MARK: - DVR
extension AVFoundationPlayback {
    open override var minDvrSize: Double {
        return 60.0
    }

    open override var usingDVR: Bool {
        guard playbackType == .live else { return false }
        guard let currentTime = player?.currentTime().seconds else { return false }
        return seekableTimeRanges.first(where: { $0.timeRangeValue.end.seconds > currentTime}) != nil
    }

    open override var seekableTimeRanges: [NSValue] {
        guard let ranges = player?.currentItem?.seekableTimeRanges else { return [] }
        return ranges
    }

    open override var loadedTimeRanges: [NSValue] {
        guard let ranges = player?.currentItem?.loadedTimeRanges else { return [] }
        return ranges
    }

    open override var supportDVR: Bool {
        guard playbackType == .live else { return false }
        return seekableTimeRanges.first(where: { $0.timeRangeValue.duration.seconds >= minDvrSize}) != nil
    }
}
