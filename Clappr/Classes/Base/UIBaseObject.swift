import Foundation

open class UIBaseObject: UIView, EventProtocol {
    fileprivate let baseObject = BaseObject()

    @discardableResult
    open func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return baseObject.on(eventName, callback: callback)
    }

    @discardableResult
    open func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return baseObject.once(eventName, callback: callback)
    }

    open func off(_ listenId: String) {
        baseObject.off(listenId)
    }

    open func trigger(_ eventName: String) {
        baseObject.trigger(eventName)
        Logger.logDebug("[\(eventName)] triggered", scope: logIdentifier())
    }

    open func trigger(_ eventName: String, userInfo: [AnyHashable: Any]?) {
        baseObject.trigger(eventName, userInfo: userInfo)
        Logger.logDebug("[\(eventName)] triggered with \(String(describing: userInfo))", scope: logIdentifier())
    }

    @discardableResult
    open func listenTo<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return baseObject.listenTo(contextObject, eventName: eventName, callback: callback)
    }

    @discardableResult
    open func listenToOnce<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return baseObject.listenToOnce(contextObject, eventName: eventName, callback: callback)
    }

    open func stopListening() {
        baseObject.stopListening()
    }

    open func stopListening(_ listenId: String) {
        baseObject.stopListening(listenId)
    }

    open func getEventContextObject() -> BaseObject {
        return baseObject
    }

    fileprivate func logIdentifier() -> String {
        if let plugin = self as? Plugin {
            return plugin.pluginName
        }
        return "\(type(of: self))"
    }

    open func render() {}

    deinit {
        Logger.logDebug("deinit", scope: NSStringFromClass(type(of: self)))
    }
}

public extension UIBaseObject {
    public func trigger(_ event: Event) {
        trigger(event.rawValue)
    }

    public func trigger(_ event: Event, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}
