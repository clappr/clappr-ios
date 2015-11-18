import Foundation

public class Playback: UIBaseObject {
    public internal(set) var url: NSURL
    
    public init(url: NSURL) {
        self.url = url
        super.init(frame: CGRect.zero)
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
    
    public func duration() -> Int {
        return 0
    }
    
    public func type() -> PlaybackType {
        return .Unknown
    }
    
    public func isPlaying() -> Bool {
        return false
    }
    
    public func isHighDefinitionInUse() -> Bool {
        return false
    }
    
    public func play() {}
    public func pause() {}
    public func stop() {}
    public func seekTo(timeInterval: NSTimeInterval) {}
}