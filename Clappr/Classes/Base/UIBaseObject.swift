import Foundation

open class UIBaseObject: UIView, EventProtocol {
    fileprivate let dispatcher = EventDispatcher()

    @discardableResult
    open func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return dispatcher.on(eventName, callback: callback)
    }

    @discardableResult
    open func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return dispatcher.once(eventName, callback: callback)
    }

    open func off(_ listenId: String) {
        dispatcher.off(listenId)
    }

    open func trigger(_ eventName: String) {
        dispatcher.trigger(eventName)
        Logger.logDebug("[\(eventName)] triggered", scope: logIdentifier())
    }

    open func trigger(_ eventName: String, userInfo: EventUserInfo) {
        dispatcher.trigger(eventName, userInfo: userInfo)
        Logger.logDebug("[\(eventName)] triggered with \(String(describing: userInfo))", scope: logIdentifier())
    }

    @discardableResult
    open func listenTo<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return dispatcher.listenTo(contextObject, eventName: eventName, callback: callback)
    }

    @discardableResult
    open func listenToOnce<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return dispatcher.listenToOnce(contextObject, eventName: eventName, callback: callback)
    }

    open func stopListening() {
        dispatcher.stopListening()
    }

    open func stopListening(_ listenId: String) {
        dispatcher.stopListening(listenId)
    }

    open func getEventContextObject() -> EventDispatcher {
        return dispatcher
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
