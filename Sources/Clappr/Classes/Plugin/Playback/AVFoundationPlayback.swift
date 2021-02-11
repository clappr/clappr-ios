import AVFoundation

open class AVFoundationPlayback: Playback, AVPlayerItemInfoDelegate {
    open class override var name: String { "AVPlayback" }

    private static let mimeTypes = [
        "mp4": "video/mp4",
        "m3u8": "application/x-mpegurl",
    ]

    private(set) var seekToTimeWhenReadyToPlay: TimeInterval?
    private var selectedCharacteristics: [AVMediaCharacteristic] = []

    @objc dynamic var player: AVPlayer!
    @objc dynamic private var playerLooper: AVPlayerLooper? {
        didSet {
            loopObserver = playerLooper?.observe(\.loopCount) { [weak self] _, _ in
                self?.trigger(.didLoop)
            }
        }
    }
    
    var itemInfo: AVPlayerItemInfo?
    private var playerLayer: AVPlayerLayer!
    private var playerStatus: AVPlayerItem.Status = .unknown
    private var isStopped = false
    private var timeObserver: Any?
    private var asset: AVURLAsset?
    private var canTriggerWillPause = true
    private(set) var loopObserver: NSKeyValueObservation?
    private var lastBitrate: Double?
    
    private var isExternalPlaybackEnabled: Bool {
        let disableExternalPlayback = options.bool(kDisableExternalPlayback)
        return !disableExternalPlayback
    }

    private var observers = [NSKeyValueObservation]()

    private var lastLogEvent: AVPlayerItemAccessLogEvent? { player.currentItem?.accessLog()?.events.last }
    private var numberOfDroppedVideoFrames: Int? { lastLogEvent?.numberOfDroppedVideoFrames }
    
    open var bitrate: Double? { lastLogEvent?.indicatedBitrate }
    open var bandwidth: Double? { lastLogEvent?.observedBitrate }
    open var averageBitrate: Double? { lastLogEvent?.averageVideoBitrate }
    open var droppedFrames: Int = 0
    open var decodedFrames: Int? { -1 }
    open var domainHost: String? { asset?.url.host }

    var lastDvrAvailability: Bool?
    #if os(tvOS)
    lazy var nowPlayingService: AVFoundationNowPlayingService = {
        return AVFoundationNowPlayingService()
    }()
    #endif

    private var currentState: PlaybackState = .idle
    override open var state: PlaybackState {
        get {
            return currentState
        }
        set {
            currentState = newValue
            updateAccesibilityIdentifier()
        }
    }

    #if os(tvOS)
    private let minSizeToShowSubtitle = CGSize(width: 560, height: 312)
    #else
    private let minSizeToShowSubtitle = CGSize(width: 280, height: 156)
    #endif

    private var lastSelectedSubtitle: MediaOption?

    private func hideSubtitleForSmallScreen() {
        if view.frame.width < minSizeToShowSubtitle.width || view.frame.height < minSizeToShowSubtitle.height {
            self.selectedSubtitle = MediaOption.offSubtitle
        } else {
            self.selectedSubtitle = lastSelectedSubtitle
        }
    }

    open override var selectedSubtitle: MediaOption? {
        get {
            guard subtitles?.isEmpty == false else { return nil }
            let option = getSelectedMediaOptionWithCharacteristic(.legible)
            return MediaOptionFactory.subtitle(from: option)
        }
        set {
            if newValue == MediaOption.offSubtitle {
                setMediaSelectionOption(nil, characteristic: .legible)
            } else {
                lastSelectedSubtitle = newValue
                let newOption = newValue?.avMediaSelectionOption
                setMediaSelectionOption(newOption, characteristic: .legible)
            }

            triggerMediaOptionSelectedEvent(option: newValue, event: .didSelectSubtitle)
        }
    }

    open override var selectedAudioSource: MediaOption? {
        get {
            let option = getSelectedMediaOptionWithCharacteristic(.audible)
            return MediaOptionFactory.fromAVMediaOption(option, type: .audioSource)
        }
        set {
            if let newOption = newValue?.avMediaSelectionOption {
                setMediaSelectionOption(newOption, characteristic: .audible)
            }
            triggerMediaOptionSelectedEvent(option: newValue, event: Event.didSelectAudio)
        }
    }

    func triggerMediaOptionSelectedEvent(option: MediaOption?, event: Event) {
        var userInfo: EventUserInfo = nil

        if option != nil {
            userInfo = ["mediaOption": option as Any]
        }

        trigger(event.rawValue, userInfo: userInfo)
    }

    open override var subtitles: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(.legible) else { return [] }
        return extracMediaOptions(in: mediaGroup, ofType: .subtitle) + [MediaOption.offSubtitle]
    }

    open override var audioSources: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(.audible) else { return [] }
        return extracMediaOptions(in: mediaGroup, ofType: .audioSource)
    }
    
    private func extracMediaOptions(in mediaGroup: AVMediaSelectionGroup, ofType type: MediaOptionType) -> [MediaOption] {
        if let cache = asset?.assetCache, cache.isPlayableOffline {
            return cache.mediaSelectionOptions(in: mediaGroup).compactMap({ MediaOptionFactory.fromAVMediaOption($0, type: type) })
        }
        return mediaGroup.options.compactMap({ MediaOptionFactory.fromAVMediaOption($0, type: type) })
    }

    open override var duration: Double {
        return itemInfo?.duration ?? .zero
    }

    open override var position: Double {
        if let start = dvrWindowStart,
            let currentTime = player.currentItem?.currentTime().seconds {
            return currentTime - start
        }
        guard playbackType == .vod else { return 0 }
        return CMTimeGetSeconds(player.currentTime())
    }

    open override var playbackType: PlaybackType {
        return itemInfo?.playbackType ?? .unknown
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

    open override var canPlay: Bool {
        switch state {
        case .idle, .paused:
            return true
        case .stalling:
            return isReadyToPlay
        default:
            return false
        }
    }

    open override var canPause: Bool {
        switch state {
        case .idle, .playing, .stalling:
            if playbackType == .live {
                return isDvrAvailable
            }
            return true
        default:
            return false
        }
    }

    open override var canSeek: Bool {
        return playbackType == .live ? isDvrAvailable : !duration.isZero
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable)
    public required init(context _: UIObject) {
        fatalError("init(context:) has not been implemented")
    }
    
    public required init(options: Options) {
        super.init(options: options)
        
        asset = createAsset(from: options[kSourceUrl] as? String)
        
        player = createAVPlayer(with: asset, shouldLoop: options[kLoop] as? Bool ?? false)
        player.allowsExternalPlayback = isExternalPlaybackEnabled
        player.appliesMediaSelectionCriteriaAutomatically = false
        
        playerLayer = AVPlayerLayer(player: player)
        
        setAudioSessionCategory(to: .playback)
    }
    
    private func createAsset(from sourceUrl: String?) -> AVURLAsset? {
        guard let urlString = sourceUrl, let url = URL(string: urlString) else { return nil }
        return AVURLAssetWithCookiesBuilder(url: url).asset
    }

    @objc public func setDelegate(_ delegate: AVAssetResourceLoaderDelegate) {
        asset?.resourceLoader.setDelegate(delegate, queue: DispatchQueue(label: "\(String(describing: asset?.url))-delegateQueue"))
    }

    open override func play() {
        guard canPlay else { return }
        trigger(.willPlay)
        if state == .stalling { trigger(.stalling) }
        player.play()
        updateInitialStateIfNeeded()
    }

    private func updateInitialStateIfNeeded() {
        guard let item = player.currentItem, item.isPlaybackLikelyToKeepUp else { return }
        updateState(.stalling)
    }

    private var canStartAt: Bool {
        return startAt != 0.0 && playbackType == .vod
    }
    
    private var canLiveStartAtTime: Bool {
        return isDvrAvailable && isEpochInsideDVRWindow(liveStartTime)
    }

    private func createAVPlayer(with asset: AVAsset? = nil, shouldLoop: Bool) -> AVPlayer {
        var player: AVPlayer
        
        if let asset = asset {
            let item = AVPlayerItem(asset: asset)
            itemInfo = AVPlayerItemInfo(item: item, delegate: self)
            
            player = shouldLoop ? AVQueuePlayer(playerItem: item): AVPlayer(playerItem: item)
            
            if let player = player as? AVQueuePlayer {
                playerLooper = AVPlayerLooper(player: player, templateItem: item)
            }
        } else {
            player = shouldLoop ? AVQueuePlayer(): AVPlayer()
        }
        
        return player
    }
    
    func didLoadDuration() {
        trigger(.didUpdateDuration, userInfo: ["duration": duration])
        trigger(.assetReady)
        seekToStartAtIfNeeded()
    }
    
    func didLoadCharacteristics() {
        selectDefaultAudioIfNeeded()
        selectDefaultSubtitleIfNeeded()
    }
    
    private func observe(player: AVPlayer) {
        observers += [
            view.observe(\.bounds) { [weak self] view, _ in
                self?.maximizePlayer(within: view)
                self?.hideSubtitleForSmallScreen()
            },
            player.observe(\.currentItem) { [weak itemInfo] player, _ in itemInfo?.update(item: player.currentItem) },
            player.observe(\.currentItem?.status) { [weak self] player, _ in self?.handleStatusChangedEvent(player) },
            player.observe(\.currentItem?.loadedTimeRanges) { [weak self] player, _ in self?.triggerDidUpdateBuffer(with: player) },
            player.observe(\.currentItem?.seekableTimeRanges) { [weak self] player, _ in self?.handleSeekableTimeRangesEvent(player) },
            player.observe(\.currentItem?.isPlaybackLikelyToKeepUp) { [weak self] player, _ in self?.handlePlaybackLikelyToKeepUp(player) },
            player.observe(\.currentItem?.isPlaybackBufferEmpty) { [weak self] player, _ in self?.handlePlaybackBufferEmpty(player) },
            player.observe(\.isExternalPlaybackActive) { [weak self] player, _ in self?.updateAirplayStatus(from: player) },
            player.observe(\.timeControlStatus) { [weak self] player, _ in self?.triggerStallingIfNeeded(player) },
            player.observe(\.rate, options: .prior) { [weak self] player, changes in self?.handlePlayerRateChanged(player, changes) },
        ]
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAccessLogEntry),
            name: .AVPlayerItemNewAccessLogEntry,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onFailedToPlayToEndTime),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: nil
        )
    }

    private func triggerSetupError() {
        trigger(.error)
        Logger.logError("could not setup player", scope: pluginName)
    }

    private func seekToStartAtIfNeeded() {
        guard canStartAt else { return }
        
        seek(startAt)
    }
    
    private func seekToLiveStartTime() {
        guard let liveStartTime = liveStartTime else { return }
        
        let positionToSeek = liveStartTime - epochDvrWindowStart
        
        seek(positionToSeek)
    }

    #if os(tvOS)
    internal func loadMetadata() {
        if let playerItem = player?.currentItem {
            nowPlayingService.setItems(to: playerItem, with: options)
        }
    }
    #endif

    @objc func playbackDidEnd(notification: NSNotification?) {
        guard didFinishedItem(from: notification) else { return }
        trigger(.didComplete)
        updateState(.idle)
        droppedFrames = 0
    }

    @objc func onFailedToPlayToEndTime(notification: NSNotification?) {
        let errorKey = "AVPlayerItemFailedToPlayToEndTimeErrorKey"
        
        if let error = notification?.userInfo?[errorKey] as? NSError {
            trigger(.error, userInfo: ["error": error])
        } else {
            let defaultError = createFailedToPlayToEndError()
            trigger(.error, userInfo: ["error": defaultError])
        }
    }
    
    @objc func onAccessLogEntry(notification: NSNotification?) {
        updateDroppedFrames()
        updateBitrate()
    }

    private func createFailedToPlayToEndError() -> NSError {
        let userInfo = [
            "AVPlayerItemFailedToPlayToEndTimeErrorKey": "defaultError"
        ]
        let error = NSError(domain: "AVPlayer", code: 0, userInfo: userInfo)
        
        return error
    }
    
    private func updateBitrate() {
        guard lastBitrate != bitrate else { return }
        
        lastBitrate = bitrate
        if let lastBitrate = lastBitrate, !lastBitrate.isNaN {
            trigger(.didUpdateBitrate, userInfo: ["bitrate": lastBitrate])
        } else {
            trigger(.didUpdateBitrate)
        }
    }

    private func updateDroppedFrames() {
        guard let numberOfDroppedVideoFrames = numberOfDroppedVideoFrames, numberOfDroppedVideoFrames > 0 else { return }

        droppedFrames += numberOfDroppedVideoFrames
    }

    private func handlePlaybackLikelyToKeepUp(_ player: AVPlayer) {
        guard state != .paused else { return }

        if hasEnoughBufferToPlay {
            play()
        }
    }
    
    private var hasEnoughBufferToPlay: Bool {
        return player.currentItem?.isPlaybackLikelyToKeepUp == true && state == .stalling
    }
    
    private func handlePlaybackBufferEmpty(_ player: AVPlayer) {
        guard state != .paused else { return }
        updateState(.stalling)
    }

    private func maximizePlayer(within view: UIView) {
        playerLayer.frame = view.bounds
        setupMaxResolution(for: playerLayer.frame.size)
    }

    private func handleStatusChangedEvent(_ player: AVPlayer) {
        guard let currentItem = player.currentItem, playerStatus != currentItem.status else { return }
        playerStatus = currentItem.status

        if isReadyToPlay && state != .paused {
            readyToPlay()
        } else if playerStatus == .failed, let error = currentItem.error {
            trigger(.error, userInfo: ["error": error])
            Logger.logError("playback failed with error: \(error.localizedDescription) ", scope: pluginName)
        }
    }

    private func triggerDidUpdateBuffer(with player: AVPlayer) {
        guard let timeRange = player.currentItem?.loadedTimeRanges.first?.timeRangeValue else { return }
        let info = [
            "start_position": CMTimeGetSeconds(timeRange.start),
            "end_position": CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration)),
            "duration": CMTimeGetSeconds(timeRange.duration),
        ]
        trigger(.didUpdateBuffer, userInfo: info)
    }

    private func handleSeekableTimeRangesEvent(_ player: AVPlayer) {
        guard !seekableTimeRanges.isEmpty else { return }
        trigger(.seekableUpdate, userInfo: ["seekableTimeRanges": seekableTimeRanges])

        handleDvrAvailabilityChange()
    }

    private func updateAirplayStatus(from player: AVPlayer) {
        trigger(.didUpdateAirPlayStatus, userInfo: ["externalPlaybackActive": player.isExternalPlaybackActive])
    }
    
    private func setAudioSessionCategory(to category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions = []) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: .moviePlayback, options: options)
        } catch {
            Logger.logError("It was not possible to set the audio session category")
        }
    }
    
    private func triggerWillPause() {
        if canTriggerWillPause {
            canTriggerWillPause = false
            trigger(.willPause)
        }
    }

    private func handlePlayerRateChanged(_ player: AVPlayer, _ changes: NSKeyValueObservedChange<Float>) {
        guard playerStatus != .unknown else { return }
        if changes.isPrior && player.rate != 0.0 && state == .playing {
            triggerWillPause()
        } else if !changes.isPrior && player.rate == 0 && state != .idle {
            updateState(.paused)
        }
    }

    private func triggerStallingIfNeeded(_ player: AVPlayer) {
        if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            updateState(.stalling)
        }
    }

    private func didFinishedItem(from notification: NSNotification?) -> Bool {
        guard let object = notification?.object as? AVPlayerItem,
            let item = player.currentItem,
            object == item,
            item.isFinished() else { return false }
        return true
    }

    open override func pause() {
        guard canPause else { return }
        triggerWillPause()
        if state == .stalling { trigger(.stalling) }
        player.pause()
        updateState(.paused)
    }

    open override func stop() {
        guard state != .idle else { return }
        
        isStopped = true
        trigger(.willStop)
        updateState(.idle)
        player.pause()
        releaseResources()
        resetPlaybackProperties()
        trigger(.didStop)
    }

    @objc func releaseResources() {
        removeObservers()
        playerLayer.removeFromSuperlayer()
        player.replaceCurrentItem(with: nil)
    }

    private func resetPlaybackProperties() {
        droppedFrames = 0
        playerStatus = .unknown
    }

    @objc var isReadyToPlay: Bool {
        return player.currentItem?.status == .readyToPlay
    }

    open override func seek(_ timeInterval: TimeInterval) {
        guard canSeek else { return }
        seek(relativeTime(to: timeInterval)) { [weak self] in
            self?.triggerDvrStatusIfNeeded()
        }
    }

    private func relativeTime(to time: TimeInterval) -> TimeInterval {
        return isDvrAvailable ? time + (dvrWindowStart ?? 0) : time
    }

    private func triggerDvrStatusIfNeeded() {
        if isDvrAvailable {
            trigger(.didChangeDvrStatus, userInfo: ["inUse": isDvrInUse])
        }
    }

    private func seek(_ timeInterval: TimeInterval, _ triggerEvent: (() -> Void)?) {
        guard isReadyToPlay else {
            seekToTimeWhenReadyToPlay = timeInterval
            return
        }

        let newPosition = CMTimeGetSeconds(timeInterval.seek().time)
        let userInfo = ["position": newPosition]

        trigger(.willSeek, userInfo: userInfo)

        player.currentItem?.seek(to: timeInterval) { [weak self] in
            self?.trigger(.didUpdatePosition, userInfo: userInfo)
            self?.trigger(.didSeek, userInfo: userInfo)
            self?.triggerStateEvents()
            triggerEvent?()
        }
    }
    
    private func triggerStateEvents() {
        switch state {
        case .playing:
            trigger(.playing)
        case .paused:
            trigger(.didPause)
        case .stalling:
            trigger(.stalling)
        default:
            break
        }
    }

    open override func seekToLivePosition() {
        guard canSeek else { return }
        play()
        seek(.infinity)
    }

    open override func mute(_ enabled: Bool) {
        player.volume = enabled ? .zero : 1.0
    }

    private func updateState(_ newState: PlaybackState) {
        guard state != newState else { return }
        state = newState

        switch state {
        case .stalling:
            trigger(.stalling)
        case .paused:
            if isStopped {
                isStopped = false
            } else {
                trigger(.didPause)
                canTriggerWillPause = true
            }
            triggerDvrStatusIfNeeded()
        case .playing:
            trigger(.playing)
        default:
            break
        }
    }

    func handleDvrAvailabilityChange() {
        if dvrAvailabilityChanged {
            trigger(.didChangeDvrAvailability, userInfo: ["available": isDvrAvailable])
            lastDvrAvailability = isDvrAvailable
            
            if canLiveStartAtTime {
                seekToLiveStartTime()
            }
        }
    }

    private var dvrAvailabilityChanged: Bool {
        return playbackType == .live && lastDvrAvailability != isDvrAvailable
    }

    @objc internal func seekOnReadyIfNeeded() {
        if let timeToSeek = seekToTimeWhenReadyToPlay {
            seek(timeToSeek)
            seekToTimeWhenReadyToPlay = nil
        }
    }

    private func readyToPlay() {
        seekOnReadyIfNeeded()
        addTimeElapsedCallback()
        #if os(tvOS)
        loadMetadata()
        #endif
    }

    @discardableResult
    open func applySubtitleStyle(with textStyle: [TextStyle]) -> Bool {
        guard let currentItem = player.currentItem else { return false }
        currentItem.textStyle = textStyle

        return true
    }

    private var defaultSubtitleLanguage: String? {
        return options[kDefaultSubtitle] as? String
    }

    private var defaultAudioSource: String? {
        return options[kDefaultAudioSource] as? String
    }

    private func defaultMediaOption(for source: [MediaOption], with language: String?) -> AVMediaSelectionOption? {
        source.first { $0.language == language }?.avMediaSelectionOption
    }
    
    func selectDefaultSubtitleIfNeeded() {
        guard let subtitles = subtitles else { return }
        var isFirstSelection = false
        let defaultSubtitle = defaultMediaOption(for: subtitles, with: defaultSubtitleLanguage) ?? mediaSelectionGroup(.legible)?.defaultOption
        if let selectedOption = defaultSubtitle, !selectedCharacteristics.contains(.legible) {
            lastSelectedSubtitle = MediaOptionFactory.fromAVMediaOption(selectedOption, type: .subtitle)
            isFirstSelection = true
            setMediaSelectionOption(selectedOption, characteristic: .legible)
            hideSubtitleForSmallScreen()
        }
        trigger(.didFindSubtitle, userInfo: ["subtitles": AvailableMediaOptions(subtitles, hasDefaultSelected: isFirstSelection)])
    }

    func selectDefaultAudioIfNeeded() {
        guard let audios = audioSources else { return }
        var isFirstSelection = false
        let defaultAudio = defaultMediaOption(for: audios, with: defaultAudioSource)
        if let selectedOption = defaultAudio, !selectedCharacteristics.contains(.audible) {
            isFirstSelection = true
            setMediaSelectionOption(selectedOption, characteristic: .audible)
        }
        trigger(.didFindAudio, userInfo: ["audios": AvailableMediaOptions(audios, hasDefaultSelected: isFirstSelection)])
    }

    private func addTimeElapsedCallback() {
        let interval = CMTimeMakeWithSeconds(0.2, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }

    private func timeUpdated(_ time: CMTime) {
        if player.rate != 0.0 {
            updateState(.playing)
            trigger(.didUpdatePosition, userInfo: ["position": CMTimeGetSeconds(time)])
        }
    }

    private func setMediaSelectionOption(_ option: AVMediaSelectionOption?, characteristic: AVMediaCharacteristic) {
        if let group = mediaSelectionGroup(characteristic) {
            selectedCharacteristics.append(characteristic)
            player.currentItem?.select(option, in: group)
        }
    }

    private func getSelectedMediaOptionWithCharacteristic(_ characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let group = mediaSelectionGroup(characteristic) else { return nil }
        return player.currentItem?.selectedMediaOption(in: group)
    }

    private func mediaSelectionGroup(_ characteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        return player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: characteristic)
    }

    deinit {
        removeObservers()
        NotificationCenter.default.removeObserver(self)
    }

    private func removeObservers() {
        guard player.observationInfo != nil else { return }

        removeTimeObserver()
        loopObserver = nil
        removePlayerObservers()
    }

    private func removeTimeObserver() {
        guard let timeObserver = timeObserver else { return }

        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }

    private func removePlayerObservers() {
        observers.forEach { $0.invalidate() }
        observers.removeAll()
    }

    override open func destroy() {
        super.destroy()
        Logger.logDebug("destroying", scope: "AVFoundationPlayback")
        releaseResources()
        Logger.logDebug("destroyed", scope: "AVFoundationPlayback")
    }

    open override func render() {
        view.layer.addSublayer(playerLayer)
        playerLayer?.frame = view.bounds
        setupMaxResolution(for: playerLayer.frame.size)
        
        observe(player: player)
        
        if asset != nil {
            trigger(.ready)
        }
        
        super.render()
    }

    private func updateAccesibilityIdentifier() {
        switch currentState {
        case .stalling:
            view.accessibilityIdentifier = "AVFoundationPlaybackStalling"
        case .paused:
            view.accessibilityIdentifier = "AVFoundationPlaybackPaused"
        case .playing:
            view.accessibilityIdentifier = "AVFoundationPlaybackPlaying"
        case .idle:
            view.accessibilityIdentifier = "AVFoundationPlaybackIdle"
        case .none:
            view.accessibilityIdentifier = "AVFoundationPlaybackNone"
        case .error:
            view.accessibilityIdentifier = "AVFoundationPlaybackError"
        }
    }
}
