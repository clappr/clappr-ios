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

    public var selectedSubtitle: AVMediaSelectionOption? {
        get {
            return nil
        }
        set {
            // no default implementation
        }
    }

    public var selectedAudioSource: AVMediaSelectionOption? {
        get {
            return nil
        }
        set {
            // no default implementation
        }
    }

    public var subtitles: [AVMediaSelectionOption]? {
        return nil
    }

    public var audioSources: [AVMediaSelectionOption]? {
        return nil
    }
    
    public required init() {
        options = [:]
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
    }

    public internal(set) var options: Options
    
    public var autoPlay: Bool {
        guard let autoPlay = options[kAutoPlay] as? Bool else {
            return false
        }
        return autoPlay
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

    public func settings() -> [String : AnyObject] {
        return [:]
    }
    
    public func duration() -> Double {
        return 0
    }
    
    public func playbackType() -> PlaybackType {
        return .Unknown
    }
    
    public func isPlaying() -> Bool {
        return false
    }
    
    public func isHighDefinitionInUse() -> Bool {
        return false
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
    public func seekTo(timeInterval: NSTimeInterval) {}
    public func setAudioSource(audioOption: AVMediaSelectionOption) {}
    public func setSubtitle(subtitleOption: AVMediaSelectionOption) {}
}