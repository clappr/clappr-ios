import Foundation

public class Playback: UIBaseObject {
    public internal(set) var url: NSURL
    public internal(set) var settings: [String : AnyObject] = [:]
    public internal(set) var duration: Int = 0
    public internal(set) var type: PlaybackType = .Unknown
    public internal(set) var isPlaying = false
    public internal(set) var isHighDefinitionInUse = false
    
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
    
    public func play() {}
    public func pause() {}
    public func stop() {}
    public func seekTo(timeInterval: NSTimeInterval) {}
}