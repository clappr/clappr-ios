import AVFoundation

public class Playback: UIBaseObject, Plugin {
    public class var type: PluginType { return .Playback }

    public class var name: String {
        return self.init().pluginName
    }

    public var pluginName: String {
        NSException(name: "MissingPluginName", reason: "Playback Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }

    public var selectedSubtitle: MediaOption?
    public var selectedAudioSource: MediaOption?
    public private(set) var subtitles: [MediaOption]?
    public private(set) var audioSources: [MediaOption]?

    public internal(set) var options: Options

    public var source: String? {
        return options[kSourceUrl] as? String
    }

    public var autoPlay: Bool {
        return options[kAutoPlay] as? Bool ?? false
    }
    
    public var startAt: NSTimeInterval {
        return options[kStartAt] as? NSTimeInterval ?? 0
    }

    public var isPlaying: Bool {
        return false
    }

    public var isPaused: Bool {
        return false
    }

    public var isBuffering: Bool {
        return false
    }

    public var duration: Double {
        return 0
    }

    public var position: Double {
        return 0
    }

    public var settings: [String : AnyObject] {
        return [:]
    }

    public var playbackType: PlaybackType {
        return .Unknown
    }

    public var isHighDefinitionInUse: Bool {
        return false
    }

    public required init() {
        options = [:]
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
    }

    public required init(options: Options) {
        self.options = options
        super.init(frame: CGRect.zero)
        userInteractionEnabled = false
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }

    public required init(context: UIBaseObject) {
        fatalError("Use init(url: NSURL) instead")
    }

    public class func canPlay(options: Options) -> Bool {
        return false
    }

    public func destroy() {
        self.removeFromSuperview()
        self.stopListening()
    }

    public override func render() {
        once(PlaybackEvent.Ready.rawValue) {[unowned self] _ in
            if self.startAt != 0 {
                self.seek(self.startAt)
            }

            self.selectDefaultMediaOptions()
        }

        if autoPlay {
            play()
        }
    }

    private func selectDefaultMediaOptions() {
        if let defaultSubtitleLanguage = options[kDefaultSubtitle] as? String,
            let defaultSubtitle = subtitles?.filter({$0.language == defaultSubtitleLanguage}).first {
            selectedSubtitle = defaultSubtitle
        }

        if let defaultAudioLanguage = options[kDefaultAudioSource] as? String,
            let defaultAudioSource = audioSources?.filter({$0.language == defaultAudioLanguage}).first {
            selectedAudioSource = defaultAudioSource
        }
    }

    internal func trigger(event: PlaybackEvent) {
        trigger(event.rawValue)
    }

    internal func trigger(event: PlaybackEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }

    public func play() {}
    public func pause() {}
    public func stop() {}
    public func seek(timeInterval: NSTimeInterval) {}
}
