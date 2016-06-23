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

    public var selectedSubtitle: Subtitle?
    public var selectedAudioSource: AudioSource?
    public private(set) var subtitles: [Subtitle]?
    public private(set) var audioSources: [AudioSource]?

    public internal(set) var options: Options

    public var source: String? {
        return options[kSourceUrl] as? String
    }

    public var autoPlay: Bool {
        guard let autoPlay = options[kAutoPlay] as? Bool else {
            return false
        }
        return autoPlay
    }

    public var isPlaying: Bool {
        return false
    }

    public var duration: Double {
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

    public class func canPlay(options: Options) -> Bool {
        return false
    }

    public func destroy() {
        self.removeFromSuperview()
        self.stopListening()
    }

    public override func render() {
        if autoPlay {
            play()
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
