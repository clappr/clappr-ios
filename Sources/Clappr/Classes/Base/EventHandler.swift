import Foundation

public typealias EventUserInfo = [AnyHashable: Any]?

public typealias EventCallback = (_ userInfo: EventUserInfo) -> Void

open class EventHandler: NSObject {

    fileprivate var callback: EventCallback?

    public init(callback: @escaping EventCallback) {
        self.callback = callback
    }

    open func handleEvent(_ notification: Notification) {
        callback?(notification.userInfo)
    }
}
