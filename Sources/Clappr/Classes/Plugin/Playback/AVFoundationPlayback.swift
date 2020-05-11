import AVFoundation

open class AVFoundationPlayback: Playback {
    open class override var name: String { "AVPlayback" }

    private static let mimeTypes = [
        "mp4": "video/mp4",
        "m3u8": "application/x-mpegurl",
    ]

    private(set) var seekToTimeWhenReadyToPlay: TimeInterval?
    private var selectedCharacteristics: [AVMediaCharacteristic] = []

    @objc dynamic var player: AVPlayer?
    @objc dynamic private var playerLooper: AVPlayerLooper? {
        didSet {
            loopObserver = observe(\.playerLooper?.loopCount) { [weak self] _, _ in
                self?.trigger(.didLoop)
            }
        }
    }
    private var playerLayer: AVPlayerLayer?
    private var playerStatus: AVPlayerItem.Status = .unknown
    private var isStopped = false
    private var timeObserver: Any?
    private var asset: AVURLAsset?
    private var audioSessionCategoryBackup: AVAudioSession.Category?
    private var canTriggerWillPause = true
    private(set) var loopObserver: NSKeyValueObservation?
    private var lastBitrate: Double?

    private var observers = [NSKeyValueObservation]()

    private var lastLogEvent: AVPlayerItemAccessLogEvent? { player?.currentItem?.accessLog()?.events.last }
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
        set {
            currentState = newValue
            updateAccesibilityIdentifier()
        }
        get {
            return currentState
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
        let availableOptions = mediaGroup.options.compactMap({ MediaOptionFactory.fromAVMediaOption($0, type: .subtitle) })
        return availableOptions + [MediaOption.offSubtitle]
    }

    open override var audioSources: [MediaOption]? {
        guard let mediaGroup = mediaSelectionGroup(.audible) else { return [] }
        return mediaGroup.options.compactMap({ MediaOptionFactory.fromAVMediaOption($0, type: .audioSource) })
    }

    open override var duration: Double {
        var durationTime: Double = 0
        guard let assetDuration = player?.currentItem?.asset.duration else { return durationTime }

        if playbackType == .vod {
            durationTime = CMTimeGetSeconds(assetDuration)
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
        guard playbackType == .vod, let player = player else { return 0 }
        return CMTimeGetSeconds(player.currentTime())
    }

    open override var playbackType: PlaybackType {
        guard let player = player, let duration = player.currentItem?.asset.duration else { return .unknown }
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

    public required init(options: Options) {
        super.init(options: options)
        asset = createAsset(from: options[kSourceUrl] as? String)
        setAudioSessionCategory(to: .playback)
    }

    private func createAsset(from sourceUrl: String?) -> AVURLAsset? {
        guard let urlString = sourceUrl, let url = URL(string: urlString) else { return nil }
        return AVURLAssetWithCookiesBuilder(url: url).asset
    }

    @objc public func setDelegate(_ delegate: AVAssetResourceLoaderDelegate) {
        asset?.resourceLoader.setDelegate(delegate, queue: DispatchQueue(label: "\(String(describing: asset?.url))-delegateQueue"))
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public required init(context _: UIObject) {
        fatalError("init(context:) has not been implemented")
    }

    open override func play() {
        guard canPlay else { return }
        setupPlayerIfNeeded()
        trigger(.willPlay)
        if state == .stalling { trigger(.stalling) }
        player?.play()
        updateInitialStateIfNeeded()
    }

    private func updateInitialStateIfNeeded() {
        guard player?.currentItem?.isPlaybackLikelyToKeepUp == true else { return }
        updateState(.stalling)
    }

    private var shouldLoop: Bool {
        return options.bool(kLoop, orElse: false)
    }

    private var canStartAt: Bool {
        return startAt != 0.0 && playbackType == .vod
    }

    private func createPlayerInstance(with item: AVPlayerItem) {
        player = shouldLoop ? AVQueuePlayer(playerItem: item): AVPlayer(playerItem: item)
        if let player = player as? AVQueuePlayer {
            playerLooper = AVPlayerLooper(player: player, templateItem: item)
        }
        player?.allowsExternalPlayback = true
        player?.appliesMediaSelectionCriteriaAutomatically = false
    }

    private func triggerSetupError() {
        trigger(.error)
        Logger.logError("could not setup player", scope: pluginName)
    }

    private func setupPlayerIfNeeded() {
        guard player == nil else { return }
        guard let asset = asset else { return triggerSetupError() }

        createPlayerInstance(with: AVPlayerItem(asset: asset))
        playerLayer = AVPlayerLayer(player: player)
        view.layer.addSublayer(playerLayer!)
        playerLayer?.frame = view.bounds
        setupMaxResolution(for: playerLayer!.frame.size)

        asset.wait(for: .characteristics, then: selectDefaultMediaOptionIfNeeded)
        asset.wait(for: .duration, then: durationAvailable)
        setupObservers()
        addObservers()
    }

    private func durationAvailable() {
        trigger(.assetReady)
        seekToStartAtIfNeeded()
    }

    private func seekToStartAtIfNeeded() {
        if canStartAt {
            seek(startAt)
        }
    }

    #if os(tvOS)
    internal func loadMetadata() {
        if let playerItem = player?.currentItem {
            nowPlayingService.setItems(to: playerItem, with: options)
        }
    }
    #endif

    @objc func setupObservers() {
        guard let player = player else { return }
        observers += [
            view.observe(\.bounds) { [weak self] view, _ in self?.maximizePlayer(within: view) },
            player.observe(\.currentItem?.status) { [weak self] player, _ in self?.handleStatusChangedEvent(player) },
            player.observe(\.currentItem?.loadedTimeRanges) { [weak self] player, _ in self?.triggerDidUpdateBuffer(with: player) },
            player.observe(\.currentItem?.seekableTimeRanges) { [weak self] player, _ in self?.handleSeekableTimeRangesEvent(player) },
            player.observe(\.currentItem?.isPlaybackLikelyToKeepUp) { [weak self] player, _ in self?.handlePlaybackLikelyToKeepUp(player) },
            player.observe(\.currentItem?.isPlaybackBufferEmpty) { [weak self] player, _ in self?.handlePlaybackBufferEmpty(player) },
            player.observe(\.isExternalPlaybackActive) { [weak self] player, _ in self?.updateAirplayStatus(from: player) },
            player.observe(\.timeControlStatus) { [weak self] player, _ in self?.triggerStallingIfNeeded(player) },
            player.observe(\.rate, options: .prior) { [weak self] player, changes in self?.handlePlayerRateChanged(player, changes) },
        ]
    }

    @objc func addObservers() {
        guard let player = player else { return }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackDidEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onAccessLogEntry),
            name: .AVPlayerItemNewAccessLogEntry,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onFailedToPlayToEndTime),
            name: .AVPlayerItemFailedToPlayToEndTime,
            object: nil)
    }
    
    @objc func onFailedToPlayToEndTime(notification: NSNotification?) {
        let errorKey = "AVPlayerItemFailedToPlayToEndTimeErrorKey"
        guard let error = notification?.userInfo?[errorKey] as? NSError else { return }

        trigger(.error, userInfo: ["error": error])
    }
    
    @objc func playbackDidEnd(notification: NSNotification?) {
        guard didFinishedItem(from: notification) else { return }
        trigger(.didComplete)
        updateState(.idle)
        droppedFrames = 0
    }

    @objc func onAccessLogEntry(notification: NSNotification?) {
        updateDroppedFrames()
        updateBitrate()
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
        return player?.currentItem?.isPlaybackLikelyToKeepUp == true && state == .stalling
    }
    
    private func handlePlaybackBufferEmpty(_ player: AVPlayer) {
        guard state != .paused else { return }
        updateState(.stalling)
    }

    private func maximizePlayer(within view: UIView) {
        guard let playerLayer = playerLayer else { return }
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
        if player.isExternalPlaybackActive {
            enableBackgroundSession()
        } else {
            restoreBackgroundSession()
        }
        trigger(.didUpdateAirPlayStatus, userInfo: ["externalPlaybackActive": player.isExternalPlaybackActive])
    }

    private func enableBackgroundSession() {
        audioSessionCategoryBackup = AVAudioSession.sharedInstance().category
        setAudioSessionCategory(to: .playback, with: [.allowAirPlay])
    }

    private func restoreBackgroundSession() {
        if let backgroundSession = audioSessionCategoryBackup {
            setAudioSessionCategory(to: backgroundSession)
        }
    }

    private func setAudioSessionCategory(to category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions = []) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: .default, options: options)
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
            let item = player?.currentItem,
            object == item,
            item.isFinished() else { return false }
        return true
    }

    open override func pause() {
        guard canPause else { return }
        triggerWillPause()
        if state == .stalling { trigger(.stalling) }
        player?.pause()
        updateState(.paused)
    }

    open override func stop() {
        isStopped = true
        trigger(.willStop)
        updateState(.idle)
        player?.pause()
        releaseResources()
        trigger(.didStop)
    }

    @objc func releaseResources() {
        removeObservers()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player?.replaceCurrentItem(with: nil)
        player = nil
        droppedFrames = 0
    }
    
    @objc var isReadyToPlay: Bool {
        return player?.currentItem?.status == .readyToPlay
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

        trigger(.willSeek, userInfo: ["position": position])

        player?.currentItem?.seek(to: timeInterval) { [weak self] in
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
        player?.volume = enabled ? .zero : 1.0
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
        trigger(.didUpdateDuration, userInfo: ["duration": duration])
        #if os(tvOS)
        loadMetadata()
        #endif
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

    func selectDefaultMediaOptionIfNeeded() {
        selectDefaultAudioIfNeeded()
        selectDefaultSubtitleIfNeeded()
    }
    
    func selectDefaultSubtitleIfNeeded() {
        guard let subtitles = subtitles else { return }
        var isFirstSelection = false
        let defaultSubtitle = defaultMediaOption(for: subtitles, with: defaultSubtitleLanguage) ?? mediaSelectionGroup(.legible)?.defaultOption
        if let selectedOption = defaultSubtitle, !selectedCharacteristics.contains(.legible) {
            isFirstSelection = true
            setMediaSelectionOption(selectedOption, characteristic: .legible)
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
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
            self?.timeUpdated(time)
        }
    }

    private func timeUpdated(_ time: CMTime) {
        if player?.rate != 0.0 {
            updateState(.playing)
            trigger(.didUpdatePosition, userInfo: ["position": CMTimeGetSeconds(time)])
        }
    }

    private func setMediaSelectionOption(_ option: AVMediaSelectionOption?, characteristic: AVMediaCharacteristic) {
        if let group = mediaSelectionGroup(characteristic) {
            selectedCharacteristics.append(characteristic)
            player?.currentItem?.select(option, in: group)
        }
    }

    private func getSelectedMediaOptionWithCharacteristic(_ characteristic: AVMediaCharacteristic) -> AVMediaSelectionOption? {
        guard let group = mediaSelectionGroup(characteristic) else { return nil }
        return player?.currentItem?.selectedMediaOption(in: group)
    }

    private func mediaSelectionGroup(_ characteristic: AVMediaCharacteristic) -> AVMediaSelectionGroup? {
        return player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: characteristic)
    }

    deinit {
        removeObservers()
        NotificationCenter.default.removeObserver(self)
    }

    private func removeObservers() {
        guard let player = player, player.observationInfo != nil else { return }
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        loopObserver = nil
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
        super.render()
        if asset != nil {
            trigger(.ready)
        }
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
