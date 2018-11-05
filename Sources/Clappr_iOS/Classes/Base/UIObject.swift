import Foundation

open class UIObject: NSObject, EventProtocol {
    fileprivate let baseObject = BaseObject()
    @objc open var view: UIView = UIView()

    @objc @discardableResult
    open func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return baseObject.on(eventName, callback: callback)
    }

    @objc @discardableResult
    open func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return baseObject.once(eventName, callback: callback)
    }

    @objc open func off(_ listenId: String) {
        baseObject.off(listenId)
    }

    @objc open func trigger(_ eventName: String) {
        baseObject.trigger(eventName)
        Logger.logDebug("[\(eventName)] triggered", scope: logIdentifier())
    }

    @objc open func trigger(_ eventName: String, userInfo: EventUserInfo) {
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

    @objc open func stopListening() {
        baseObject.stopListening()
    }

    @objc open func stopListening(_ listenId: String) {
        baseObject.stopListening(listenId)
    }

    @objc open func getEventContextObject() -> BaseObject {
        return baseObject
    }

    fileprivate func logIdentifier() -> String {
        if let plugin = self as? Plugin {
            return plugin.pluginName
        }
        return "\(type(of: self))"
    }

    @objc open func render() {}
    

    deinit {
        Logger.logDebug("deinit", scope: NSStringFromClass(type(of: self)))
    }
}

public extension UIObject {
    public func trigger(_ event: Event) {
        trigger(event.rawValue)
    }

    public func trigger(_ event: Event, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
}
