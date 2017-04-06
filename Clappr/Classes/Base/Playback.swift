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
    open fileprivate(set) var subtitles: [MediaOption]?
    open fileprivate(set) var audioSources: [MediaOption]?

    open internal(set) var options: Options

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

    open var settings: [String : Any] {
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
        self.backgroundColor = UIColor.clear
    }

    public required init(options: Options) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.options = options
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = false
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }

    public required init(context: UIBaseObject) {
        fatalError("Use init(url: NSURL) instead")
    }

    open class func canPlay(_ options: Options) -> Bool {
        return false
    }

    open func destroy() {
        self.removeFromSuperview()
        self.stopListening()
    }

    open override func render() {
        once(Event.ready.rawValue) {[unowned self] _ in
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
            let defaultSubtitle = subtitles?.filter({$0.language == defaultSubtitleLanguage}).first {
            selectedSubtitle = defaultSubtitle
        }

        if let defaultAudioLanguage = options[kDefaultAudioSource] as? String,
            let defaultAudioSource = audioSources?.filter({$0.language == defaultAudioLanguage}).first {
            selectedAudioSource = defaultAudioSource
        }
    }

    open func play() {}
    open func pause() {}
    open func stop() {}
    open func seek(_ timeInterval: TimeInterval) {}
}
