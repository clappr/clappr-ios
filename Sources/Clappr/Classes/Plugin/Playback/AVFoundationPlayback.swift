import AVFoundation

enum PlaybackState {
    case idle, paused, playing, buffering
}

open class AVFoundationPlayback: Playback {
    private static let mimeTypes = [
        "mp4": "video/mp4",
        "m3u8": "application/x-mpegurl",
        ]

    private var kvoStatusDidChangeContext = 0
    private var kvoLoadedTimeRangesContext = 0
    private var kvoSeekableTimeRangesContext = 0
    private var kvoBufferingContext = 0
    private var kvoExternalPlaybackActiveContext = 0
    private var kvoPlayerRateContext = 0
    private var kvoViewBounds = 0

    private(set) var seekToTimeWhenReadyToPlay: TimeInterval?

    @objc internal dynamic var player: AVPlayer?
    
    #if os(tvOS)
    lazy var nowPlayingService: AVFoundationNowPlayingService = {
        return AVFoundationNowPlayingService()
    }()
    #endif
    
    private var playerLayer: AVPlayerLayer?
    private var playerStatus: AVPlayerItem.Status = .unknown
    private(set) var currentState = PlaybackState.idle {
        didSet {
            switch currentState {
            case .buffering:
                view.accessibilityIdentifier = "AVFoundationPlaybackBuffering"
            case .paused:
                view.accessibilityIdentifier = "AVFoundationPlaybackPaused"
            case .playing:
                view.accessibilityIdentifier = "AVFoundationPlaybackPlaying"
            case .idle:
                view.accessibilityIdentifier = "AVFoundationPlaybackIdle"
            }
        }
    }
    private var timeObserver: Any?
    private var asset: AVURLAsset?
    var lastDvrAvailability: Bool?

    private var backgroundSessionBackup: AVAudioSession.Category?

    open override var pluginName: String {
        return "AVPlayback"
    }

    private var hasSelectedDefaultSubtitle = false
    open override var selectedSubtitle: MediaOption? {
        get {
            guard let subtitles = self.subtitles, subtitles.count > 0 else { return nil }
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristic.legible.rawValue)
            return MediaOptionFactory.fromAVMediaOption(option, type: .subtitle) ?? MediaOptionFactory.offSubtitle()
        }
        set {
            let newOption = newValue?.raw as? AVMediaSelectionOption
            setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristic.legible.rawValue)
            triggerMediaOptionSelectedEvent(option: newValue, event: Event.didSelectSubtitle)
        }
    }

    private var hasSelectedDefaultAudio = false
    open override var selectedAudioSource: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(AVMediaCharacteristic.audible.rawValue)
            return MediaOptionFactory.fromAVMediaOption(option, type: .audioSource)
        }
        set {
            if let newOption = newValue?.raw as? AVMediaSelectionOption {
                setMediaSelectionOption(newOption, characteristic: AVMediaCharacteristic.audible.rawValue)
            }
            triggerMediaOptionSelectedEvent(option: newValue, event: Event.didSelectAudio)
        }
    }

    func triggerMediaOptionSelectedEvent(option: MediaOption?, event: Event) {
        var userInfo: EventUserInfo

        if option != nil {
            userInfo = ["mediaOption": option as Any]
        }

        trigger(event.rawValue, userInfo: userInfo)
    }

    open override var subtitles: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristic.legible.rawValue) else {
            return []
        }

        let availableOptions = mediaGroup.options.compactMap({ MediaOptionFactory.fromAVMediaOption($0, type: .subtitle) })
        return availableOptions + [MediaOptionFactory.offSubtitle()]
    }

    open override var audioSources: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(AVMediaCharacteristic.audible.rawValue) else {
            return []
        }
        return mediaGroup.options.compactMap({ MediaOptionFactory.fromAVMediaOption($0, type: .audioSource) })
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

    private var isStopped = false

    open override var duration: Double {
        guard let item = player?.currentItem else {
            return 0
        }

        var durationTime: Double = 0

        if playbackType == .vod {
            durationTime = CMTimeGetSeconds(item.asset.duration)
        } else if playbackType == .live {
            durationTime = seekableTimeRanges.reduce(0.0, { previous, current in
                previous + current.timeRangeValue.duration.seconds
            })
        }

        return durationTime
    }

    open override var position: Double {
        if isDvrAvailable, let start = dvrWindowStart,
            let position = player?.currentItem?.currentTime().seconds {
            return position - start
        }
        
        guard playbackType == .vod, let player = self.player else {
            return 0
        }
        return CMTimeGetSeconds(player.currentTime())
    }

    open override var playbackType: PlaybackType {
        guard let player = player, let duration = player.currentItem?.asset.duration else {
            return .unknown
        }

        return duration == CMTime.indefinite ? .live : .vod
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

    public required init(context _: UIObject) {
        fatalError("init(context:) has not been implemented")
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

    private func setupPlayer() {
        if let asset = self.asset {
            let item: AVPlayerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: item)
            
            player?.allowsExternalPlayback = true
            player?.appliesMediaSelectionCriteriaAutomatically = false

            selectDefaultAudioIfNeeded()

            playerLayer = AVPlayerLayer(player: player)
            view.layer.addSublayer(playerLayer!)
            playerLayer?.frame = view.bounds
            setupMaxResolution(for: playerLayer!.frame.size)

            if startAt != 0.0 && playbackType == .vod {
                seek(startAt)
            }

            addObservers()
        } else {
            trigger(.error)
            Logger.logError("could not setup player", scope: pluginName)
        }
    }
    
    #if os(tvOS)
    internal func loadMetadata() {
        if let playerItem = player?.currentItem {
            nowPlayingService.setItems(to: playerItem, with: options)
        }
    }
    #endif

    @objc internal func addObservers() {
        view.addObserver(self, forKeyPath: "bounds",
                         options: .new, context: &kvoViewBounds)

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

    @objc private func playbackDidEnd(notification: NSNotification? = nil) {
        if let object = notification?.object as? AVPlayerItem, let item = self.player?.currentItem {
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
        isStopped = true
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
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    @objc var isReadyToSeek: Bool {
        return player?.currentItem?.status == .readyToPlay
    }

    open override func seek(_ timeInterval: TimeInterval) {
        seek(relativeTime(to: timeInterval)) { [weak self] in
            self?.triggerDvrStatusIfNeeded()
        }
    }

    private func relativeTime(to time: TimeInterval) -> TimeInterval {
        if isDvrAvailable {
            return time + (dvrWindowStart ?? 0)
        } else {
            return time
        }
    }

    private func triggerDvrStatusIfNeeded() {
        if isDvrAvailable {
            trigger(.didChangeDvrStatus, userInfo: ["inUse": isDvrInUse])
        }
    }

    private func seek(_ timeInterval: TimeInterval, _ triggerEvent: (() -> Void)?) {
        if !isReadyToSeek {
            seekToTimeWhenReadyToPlay = timeInterval
            return
        }

        let time = CMTimeMakeWithSeconds(timeInterval, preferredTimescale: Int32(NSEC_PER_SEC))
        let tolerance = CMTime(value: 0, timescale: Int32(NSEC_PER_SEC))

        trigger(.willSeek)

        player?.currentItem?.seek(to: time, toleranceBefore: tolerance, toleranceAfter: tolerance) { [weak self] success in
            if success {
                self?.trigger(.didUpdatePosition, userInfo: ["position": CMTimeGetSeconds(time)])
                self?.trigger(.didSeek)
                if let triggerEvent = triggerEvent {
                    triggerEvent()
                }
            }
        }
    }

    open override func seekToLivePosition() {
        play()
        seek(Double.infinity)
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
        case &kvoViewBounds:
            handleViewBoundsChanged()
        default:
            break
        }
    }

    private func updateState(_ newState: PlaybackState) {
        guard currentState != newState else { return }
        currentState = newState

        switch newState {
        case .buffering:
            trigger(.stalling)
        case .paused:
            if isStopped {
                isStopped = false
            } else {
                trigger(.didPause)
            }

            triggerDvrStatusIfNeeded()
        case .playing:
            trigger(.playing)
        default:
            break
        }
    }

    private func handleExternalPlaybackActiveEvent() {
        guard let concretePlayer = player else {
            return
        }

        if concretePlayer.isExternalPlaybackActive {
            enableBackgroundSession()
        } else {
            restoreBackgroundSession()
        }

        self.trigger(.didUpdateAirPlayStatus, userInfo: ["externalPlaybackActive": concretePlayer.isExternalPlaybackActive])
    }
    
    private func handleStatusChangedEvent() {
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
    
    private func handleLoadedTimeRangesEvent() {
        guard let timeRange = player?.currentItem?.loadedTimeRanges.first?.timeRangeValue else {
            return
        }
        
        let info = [
            "start_position": CMTimeGetSeconds(timeRange.start),
            "end_position": CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)),
            "duration": CMTimeGetSeconds(timeRange.duration),
            ]
        
        trigger(.didUpdateBuffer, userInfo: info)
    }
    
    private func handleSeekableTimeRangesEvent() {
        guard !seekableTimeRanges.isEmpty else { return }
        trigger(.seekableUpdate, userInfo: ["seekableTimeRanges": seekableTimeRanges])
        handleDvrAvailabilityChange()
    }
    
    func handleDvrAvailabilityChange() {
        if lastDvrAvailability != isDvrAvailable {
            trigger(.didChangeDvrAvailability, userInfo: ["available": isDvrAvailable])
            lastDvrAvailability = isDvrAvailable
        }
    }
    
    private func handleBufferingEvent(_ keyPath: String?) {
        guard let keyPath = keyPath, currentState != .paused else {
            return
        }
        
        if keyPath == "currentItem.playbackLikelyToKeepUp" {
            if player?.currentItem?.isPlaybackLikelyToKeepUp == true && currentState == .buffering {
                play()
                selectDefaultSubtitleIfNeeded()
            } else {
                updateState(.buffering)
            }
        } else if keyPath == "currentItem.playbackBufferEmpty" {
            updateState(.buffering)
        }
    }
    
    private func handleViewBoundsChanged() {
        guard let playerLayer = playerLayer else {
            return
        }
        playerLayer.frame = view.bounds
        setupMaxResolution(for: playerLayer.frame.size)
    }
    
    private func handlePlayerRateChanged() {
        if player?.rate == 0 && playerStatus != .unknown && currentState != .idle {
            updateState(.paused)
        }
    }

    private func enableBackgroundSession() {
        backgroundSessionBackup = AVAudioSession.sharedInstance().category
        changeBackgroundSession(to: AVAudioSession.Category.playback)
    }

    private func restoreBackgroundSession() {
        if let concreteBackgroundSession = backgroundSessionBackup {
            changeBackgroundSession(to: concreteBackgroundSession)
        }
    }

    private func changeBackgroundSession(to category: AVAudioSession.Category) {
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(category, mode: .default, options: [.allowAirPlay])
            }
        } catch {
            print("It was not possible to set the audio session category")
        }
    }

    @objc internal func seekOnReadyIfNeeded() {
        if let timeToSeek = seekToTimeWhenReadyToPlay {
            seek(timeToSeek)
            self.seekToTimeWhenReadyToPlay = nil
        }
    }

    private func readyToPlay() {
        seekOnReadyIfNeeded()
        addTimeElapsedCallback()
        trigger(.didUpdateDuration, userInfo: ["duration": duration])
        #if os(tvOS)
            loadMetadata()
        #endif
    }

    internal func selectDefaultSubtitleIfNeeded() {
        guard let subtitles = self.subtitles else { return }
        if let defaultSubtitleLanguage = options[kDefaultSubtitle] as? String,
            let defaultSubtitle = subtitles.filter({ $0.language == defaultSubtitleLanguage }).first,
            let selectedOption = defaultSubtitle.raw as? AVMediaSelectionOption,
            !hasSelectedDefaultSubtitle {

            setMediaSelectionOption(selectedOption, characteristic: AVMediaCharacteristic.legible.rawValue)
            trigger(.didFindSubtitle, userInfo: ["subtitles": AvailableMediaOptions(subtitles, hasDefaultSelected: true)])
            hasSelectedDefaultSubtitle = true
        } else {
            trigger(.didFindSubtitle, userInfo: ["subtitles": AvailableMediaOptions(subtitles, hasDefaultSelected: false)])
        }
    }

    internal func selectDefaultAudioIfNeeded() {
        guard let audioSources = self.audioSources else { return }
        if let defaultAudioLanguage = options[kDefaultAudioSource] as? String,
            let defaultAudioSource = audioSources.filter({ $0.language == defaultAudioLanguage }).first,
            let selectedOption = defaultAudioSource.raw as? AVMediaSelectionOption,
            !hasSelectedDefaultAudio {

            setMediaSelectionOption(selectedOption, characteristic: AVMediaCharacteristic.audible.rawValue)
            trigger(.didFindAudio, userInfo: ["audios": AvailableMediaOptions(audioSources, hasDefaultSelected: true)])
            hasSelectedDefaultAudio = true
        } else {
            trigger(.didFindAudio, userInfo: ["audios": AvailableMediaOptions(audioSources, hasDefaultSelected: false)])
        }
    }

    private func addTimeElapsedCallback() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.2, preferredTimescale: 600), queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }

    private func timeUpdated(_ time: CMTime) {
        if isPlaying {
            updateState(.playing)
            trigger(.didUpdatePosition, userInfo: ["position": CMTimeGetSeconds(time)])
        }
    }


    private func setMediaSelectionOption(_ option: AVMediaSelectionOption?, characteristic: String) {
        if let group = mediaSelectionGroup(characteristic) {
            player?.currentItem?.select(option, in: group)
        }
    }

    private func getSelectedMediaOptionWithCharacteristic(_ characteristic: String) -> AVMediaSelectionOption? {
        if let group = mediaSelectionGroup(characteristic) {
            return player?.currentItem?.selectedMediaOption(in: group)
        }
        return nil
    }

    private func mediaSelectionGroup(_ characteristic: String) -> AVMediaSelectionGroup? {
        return player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic(rawValue: characteristic))
    }

    deinit {
        removeObservers()
    }

    private func removeObservers() {
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
        view.removeObserver(self, forKeyPath: "bounds")
        NotificationCenter.default.removeObserver(self)
    }

    override open func destroy() {
        super.destroy()
        Logger.logDebug("destroying", scope: "AVFoundationPlayback")
        releaseResources()
        Logger.logDebug("destroyed", scope: "AVFoundationPlayback")
    }

    open override func render() {
        super.render()
        if asset != nil {
            trigger(.ready)
        }
    }
}

// MARK: - DVR
extension AVFoundationPlayback {
    open override var minDvrSize: Double {
        return self.options[kMinDvrSize] as? Double ?? 60.0
    }

    open override var isDvrInUse: Bool {
        if isPaused && isDvrAvailable { return true }
        guard let end = dvrWindowEnd, playbackType == .live else { return false }
        guard let currentTime = player?.currentTime().seconds else { return false }
        return end - liveHeadTolerance > currentTime
    }

    open override var isDvrAvailable: Bool {
        guard playbackType == .live else { return false }
        
        return duration >= minDvrSize
    }

    open override var currentDate: Date? {
        return player?.currentItem?.currentDate()
    }

    open override var seekableTimeRanges: [NSValue] {
        guard let ranges = player?.currentItem?.seekableTimeRanges else { return [] }
        return ranges
    }

    open override var loadedTimeRanges: [NSValue] {
        guard let ranges = player?.currentItem?.loadedTimeRanges else { return [] }
        return ranges
    }

    private var dvrWindowStart: Double? {
        guard let end = dvrWindowEnd, isDvrAvailable, playbackType == .live else {
            return nil
        }
        return end - duration
    }

    private var dvrWindowEnd: Double? {
        guard isDvrAvailable, playbackType == .live else {
            return nil
        }
        return seekableTimeRanges.max { rangeA, rangeB in rangeA.timeRangeValue.end.seconds < rangeB.timeRangeValue.end.seconds }?.timeRangeValue.end.seconds
    }

    fileprivate var liveHeadTolerance: Double {
        return 5
    }
}
