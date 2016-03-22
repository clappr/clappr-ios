import Foundation

public class Playback: UIBaseObject, Plugin {
    public class var type: PluginType { return .Playback }
    
    public class var name: String {
        return self.init().pluginName
    }
    
    public var pluginName: String {
        NSException(name: "MissingPluginName", reason: "Playback Plugins should always declare a name", userInfo: nil).raise()
        return ""
    }
    
    public required init() {
        options = [:]
        super.init(frame: CGRectZero)
    }

    public internal(set) var options: Options
    
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
}