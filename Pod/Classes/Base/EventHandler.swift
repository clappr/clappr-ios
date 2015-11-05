import Foundation

public typealias EventCallback = ((userInfo: [NSObject : AnyObject]?) -> ())

public class EventHandler: NSObject {
    
    private var callback: EventCallback?
    
    public init(callback: EventCallback) {
        self.callback = callback
    }
    
    public func handleEvent(notification: NSNotification) {
        callback?(userInfo: notification.userInfo)
    }
}