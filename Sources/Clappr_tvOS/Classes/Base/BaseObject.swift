public protocol BaseObject: EventProtocol {
    var eventDispatcher: EventDispatcher { get }
}

private var eventDispatcherPointer: UInt8 = 0

extension BaseObject {
    public var eventDispatcher: EventDispatcher {
        if let eventDispatcher = objc_getAssociatedObject(self, &eventDispatcherPointer) as? EventDispatcher {
            return eventDispatcher
        } else {
            let eventDispatcher = EventDispatcher()
            objc_setAssociatedObject(self, &eventDispatcherPointer, eventDispatcher, .OBJC_ASSOCIATION_RETAIN)
            return eventDispatcher
        }
    }

    @discardableResult
    public func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return eventDispatcher.on(eventName, callback: callback)
    }

    @discardableResult
    public func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return eventDispatcher.once(eventName, callback: callback)
    }

    public func off(_ listenId: String) {
        eventDispatcher.off(listenId)
    }

    public func trigger(_ eventName: String) {
        eventDispatcher.trigger(eventName)
        Logger.logDebug("[\(eventName)] triggered", scope: logIdentifier())
    }

    public func trigger(_ eventName: String, userInfo: EventUserInfo) {
        eventDispatcher.trigger(eventName, userInfo: userInfo)
        Logger.logDebug("[\(eventName)] triggered with \(String(describing: userInfo))", scope: logIdentifier())
    }

    @discardableResult
    public func listenTo<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return eventDispatcher.listenTo(contextObject, eventName: eventName, callback: callback)
    }

    @discardableResult
    public func listenToOnce<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return eventDispatcher.listenToOnce(contextObject, eventName: eventName, callback: callback)
    }

    public func stopListening() {
        eventDispatcher.stopListening()
    }

    public func stopListening(_ listenId: String) {
        eventDispatcher.stopListening(listenId)
    }

    public func getEventDispatcher() -> EventDispatcher {
        return eventDispatcher
    }

    public func trigger(_ event: Event) {
        trigger(event.eventName())
    }

    public func trigger(_ event: Event, userInfo: EventUserInfo) {
        trigger(event.eventName(), userInfo: userInfo)
    }

    func logIdentifier() -> String {
        if let plugin = self as? Plugin {
            return plugin.pluginName
        }

        return "\(type(of: self))"
    }
}
