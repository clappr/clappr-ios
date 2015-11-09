import Foundation

public class Playback: UIBaseObject {
    public var url: NSURL
    
    public init (url: NSURL) {
        self.url = url
        super.init(frame: CGRect.zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(url: NSURL) instead")
    }
    
    public func play() {}
    public func pause() {}
    public func stop() {}
}