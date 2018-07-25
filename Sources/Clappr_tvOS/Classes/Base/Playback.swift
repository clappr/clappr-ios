import AVFoundation

open class Playback: UIBaseObject, Plugin {
    open class var type: PluginType { return .playback }

    open class var name: String {
        return self.init().pluginName
    }

    open var pluginName: String {
        NSException(name: NSExceptionName(rawValue: "MissingPluginName"), reason: "Playback Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }

    open var selectedSubtitle: MediaOption?
    open var selectedAudioSource: MediaOption?
    fileprivate(set) open var subtitles: [MediaOption]?
    fileprivate(set) open var audioSources: [MediaOption]?

    internal(set) open var options: Options

    open var source: String? {
        return options[kSourceUrl] as? String
    }

    open var autoPlay: Bool {
        return options[kAutoPlay] as? Bool ?? false
    }

    open var startAt: TimeInterval {
        return options[kStartAt] as? TimeInterval ?? 0.0
    }

    open var isPlaying: Bool {
        return false
    }

    open var isPaused: Bool {
        return false
    }

    open var isBuffering: Bool {
        return false
    }

    open var duration: Double {
        return 0.0
    }

    open var position: Double {
        return 0.0
    }

    open var settings: [String: Any] {
        return [:]
    }

    open var playbackType: PlaybackType {
        return .unknown
    }

    open var isHighDefinitionInUse: Bool {
        return false
    }

    public required init() {
        options = [:]
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear
    }

    public required init(options: Options) {
        Logger.logDebug("loading with \(options)", scope: "\(Swift.type(of: self))")
        self.options = options
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = false
    }

    public required init?(coder _: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }

    public required init(context _: UIBaseObject) {
        fatalError("Use init(url: NSURL) instead")
    }

    open class func canPlay(_: Options) -> Bool {
        return false
    }

    open override func render() {
        once(Event.ready.rawValue) { [unowned self] _ in
            if self.startAt != 0.0 {
                self.seek(self.startAt)
            }

            self.selectDefaultMediaOptions()
        }

        if autoPlay {
            play()
        }
    }

    fileprivate func selectDefaultMediaOptions() {
        if let defaultSubtitleLanguage = options[kDefaultSubtitle] as? String,
            let defaultSubtitle = subtitles?.filter({ $0.language == defaultSubtitleLanguage }).first {
            selectedSubtitle = defaultSubtitle
        }

        if let defaultAudioLanguage = options[kDefaultAudioSource] as? String,
            let defaultAudioSource = audioSources?.filter({ $0.language == defaultAudioLanguage }).first {
            selectedAudioSource = defaultAudioSource
        }
    }

    open func play() {}
    open func pause() {}
    open func stop() {}
    open func seek(_: TimeInterval) {}
    open func mute(_: Bool) {}

    open func destroy() {
        Logger.logDebug("destroying", scope: "Playback")
        Logger.logDebug("destroying ui elements", scope: "Playback")
        removeFromSuperview()
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
    
    @objc open var usingDVR: Bool {
        return false
    }
    
    @objc open var seekableTimeRanges: [NSValue] {
        return []
    }
    
    @objc open var loadedTimeRanges: [NSValue] {
        return []
    }
    
    @objc open var supportDVR: Bool {
        return false
    }
    
    @objc open var dvrPosition: Double {
        return 0
    }

    @objc open var currentDate: Date? {
        return nil
    }
}
