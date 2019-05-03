import AVFoundation

open class Playback: UIObject, Nameable {
    open class var type: PluginType { return .playback }

    @objc open class var name: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Playback Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }

    open var selectedSubtitle: MediaOption?
    open var selectedAudioSource: MediaOption?
    fileprivate(set) open var subtitles: [MediaOption]?
    fileprivate(set) open var audioSources: [MediaOption]?

    @objc internal(set) open var options: Options {
        didSet {
            trigger(Event.didUpdateOptions)
        }
    }

    @objc open var source: String? {
        return options[kSourceUrl] as? String
    }

    @objc open var startAt: TimeInterval {
        return options.startAt ?? 0.0
    }

    @objc open var isPlaying: Bool {
        return false
    }

    @objc open var isPaused: Bool {
        return false
    }

    @objc open var isBuffering: Bool {
        return false
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
        fatalError("Use init(url: NSURL) instead")
    }

    @objc open class func canPlay(_: Options) -> Bool {
        return false
    }

    open override func render() {
        #if os(tvOS)
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.play()
        }
        #endif
    }

    @objc open func play() {}
    @objc open func pause() {}
    @objc open func stop() {}
    @objc open func seek(_: TimeInterval) {}
    @objc open func seekToLivePosition() {}
    open func mute(_: Bool) {}

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
