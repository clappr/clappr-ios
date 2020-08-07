import AVFoundation

@objc public enum PlaybackState: Int {
    case none = 0
    case idle = 1
    case playing = 2
    case paused = 3
    case stalling = 4
    case error = 5
}

open class Playback: UIObject, NamedType {
    open class var type: PluginType {
        return .playback
    }

    @objc open class var name: String {
        NSException(name: NSExceptionName(rawValue: "MissingPlaybackName"), reason: "Playbacks should always declare a name. \(self) does not.", userInfo: nil).raise()
        return ""
    }

    open var selectedSubtitle: MediaOption?
    open var selectedAudioSource: MediaOption?
    fileprivate(set) open var subtitles: [MediaOption]?
    fileprivate(set) open var audioSources: [MediaOption]?
    
    var isChromeless: Bool { options.bool(kChromeless) }
    var playbackRenderer: PlaybackRendererProtocol = PlaybackRenderer()

    @objc internal(set) open var options: Options {
        didSet {
            trigger(.didUpdateOptions)
        }
    }

    @objc open var source: String? {
        return options[kSourceUrl] as? String
    }

    @objc open var startAt: TimeInterval {
        return options.startAt ?? 0.0
    }
    
    open var liveStartTime: TimeInterval? {
        return options.liveStartTime
    }

    @objc open var duration: Double {
        return 0.0
    }

    @objc open var position: Double {
        return 0.0
    }

    @objc open var settings: [String: Any] {
        return [:]
    }

    open var playbackType: PlaybackType {
        return .unknown
    }

    @objc open var state: PlaybackState {
        return .none
    }

    @objc open var isHighDefinitionInUse: Bool {
        return false
    }

    @objc public required init(options: Options) {
        Logger.logDebug("loading with \(options)", scope: "\(Swift.type(of: self))")
        self.options = options
        super.init()
        view.isUserInteractionEnabled = false
    }

    @objc public required init(context _: UIObject) {
        fatalError("Use init(options: Options) instead")
    }

    @objc open class func canPlay(_: Options) -> Bool {
        return false
    }
    
    open override func render() {
        playbackRenderer.render(playback: self)
    }

    @objc open var canPlay: Bool {
        return false
    }

    @objc open var canPause: Bool {
        return false
    }
    
    @objc open var canSeek: Bool {
        return false
    }

    @objc open func play() {}
    @objc open func pause() {}
    @objc open func stop() {}
    @objc open func seek(_: TimeInterval) {}
    @objc open func seekToLivePosition() {}
    open func mute(_: Bool) {}
    open func changeSubtitle(style textStyle: [TextStyle]) {}

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Playback")
        Logger.logDebug("destroying ui elements", scope: "Playback")
        view.removeFromSuperview()
        Logger.logDebug("destroying listeners", scope: "Playback")
        stopListening()
        Logger.logDebug("destroyed", scope: "Playback")
    }
}

// MARK: - DVR
extension Playback {
    @objc var minDvrSize: Double {
        return 0
    }

    @objc open var isDvrInUse: Bool {
        return false
    }

    @objc open var isDvrAvailable: Bool {
        return false
    }

    @objc open var currentDate: Date? {
        return nil
    }

    @objc open var currentLiveDate: Date? {
        return nil
    }
    
    @objc open var seekableTimeRanges: [NSValue] {
        return []
    }
    
    @objc open var loadedTimeRanges: [NSValue] {
        return []
    }
    
    @objc open var epochDvrWindowStart: TimeInterval {
        return 0
    }
}
