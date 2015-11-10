import Foundation

public typealias EventUserInfo = [NSObject : AnyObject]?
public typealias EventCallback = ((userInfo: EventUserInfo) -> ())

public class EventHandler: NSObject {
    
    private var callback: EventCallback?
    
    public init(callback: EventCallback) {
        self.callback = callback
    }
    
    public func handleEvent(notification: NSNotification) {
        callback?(userInfo: notification.userInfo)
    }
}