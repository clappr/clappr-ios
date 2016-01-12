import Foundation

public class Playback: UIBaseObject {
    public internal(set) var url: NSURL
    public internal(set) var type = PlaybackType.Unknown
    
    public required init(url: NSURL) {
        self.url = url
        super.init(frame: CGRect.zero)
        userInteractionEnabled = false
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }
    
    public func destroy() {
        self.removeFromSuperview()
        self.stopListening()
    }
    
    public class func canPlay(url: NSURL) -> Bool {
        return false
    }
    
    public func settings() -> [String : AnyObject] {
        return [:]
    }
    
    public func duration() -> Double {
        return 0
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