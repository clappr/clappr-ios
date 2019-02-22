import Foundation

open class UIObject: BaseObject {
    @objc open var view: UIView = UIView()
    @objc open func render() {}
}

public extension UIObject {
    public func trigger(_ event: Event) {
        trigger(event.rawValue)
    }

    public func trigger(_ event: Event, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}
