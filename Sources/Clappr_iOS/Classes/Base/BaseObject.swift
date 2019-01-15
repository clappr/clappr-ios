import Foundation

private struct EventHolder {
    var eventHandler: EventHandler
    var contextObject: BaseObject
    var name: String
}

open class BaseObject: NSObject, EventProtocol {
    fileprivate var events = [String: EventHolder]()
    fileprivate var onceEventsHashes = [String]()

    @objc @discardableResult
    open func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: self)
    }

    @discardableResult
    fileprivate func on(_ eventName: String, callback: @escaping EventCallback, contextObject: BaseObject) -> String {
        let listenId = createListenId(eventName, contextObject: contextObject)
        let eventHandler = EventHandler(callback: wrapEventCallback(listenId, callback: callback))

        events[listenId] = EventHolder(eventHandler: eventHandler, contextObject: contextObject, name: eventName)
        notificationCenter().addObserver(eventHandler, selector: #selector(EventHandler.handleEvent), name: NSNotification.Name(rawValue: eventName), object: contextObject)

        return listenId
    }

    fileprivate func wrapEventCallback(_ listenId: String, callback: @escaping EventCallback) -> EventCallback {
        return { userInfo in
            do {
                try ObjC.catchException {
                    callback(userInfo)
                }
            } catch {
                Logger.logError(error.localizedDescription, scope: "Calling callback")
            }
            self.removeListenerIfOnce(listenId, callback: callback)
        }
    }

    fileprivate func removeListenerIfOnce(_ listenId: String, callback _: EventCallback) {
        if let index = self.onceEventsHashes.index(of: listenId) {
            onceEventsHashes.remove(at: index)
            off(listenId)
        }
    }

    @objc @discardableResult
    open func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return once(eventName, callback: callback, contextObject: self)
    }

    @discardableResult
    fileprivate func once(_ eventName: String, callback: @escaping EventCallback, contextObject: BaseObject) -> String {
        let listenId = on(eventName, callback: callback, contextObject: contextObject)
        onceEventsHashes.append(listenId)
        return listenId
    }

    @objc open func off(_ listenId: String) {
        guard let event = events[listenId] else {
            Logger.logError("could not find any event with given event listenId: \(listenId)", scope: logIdentifier())
            return
        }

        notificationCenter().removeObserver(event.eventHandler, name: NSNotification.Name(rawValue: event.name), object: event.contextObject)
        events.removeValue(forKey: listenId)
    }

    @objc open func trigger(_ eventName: String) {
        trigger(eventName, userInfo: [:])
    }

    @objc open func trigger(_ eventName: String, userInfo: [AnyHashable: Any]?) {
        notificationCenter().post(name: Notification.Name(rawValue: eventName), object: self, userInfo: userInfo)

        if type(of: self) != BaseObject.self {
            Logger.logDebug("[\(eventName)] triggered with \(String(describing: userInfo))", scope: logIdentifier())
        }
    }

    @discardableResult
    open func listenTo<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }

    @discardableResult
    open func listenToOnce<T: EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return once(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }

    @objc open func stopListening() {
        for (_, event) in events {
            notificationCenter().removeObserver(event.eventHandler)
        }

        events.removeAll()
    }

    @objc open func stopListening(_ listenId: String) {
        off(listenId)
    }

    @objc open func getEventContextObject() -> BaseObject {
        return self
    }

    fileprivate func createListenId(_ eventName: String, contextObject: BaseObject) -> String {
        let contextObjectHash = ObjectIdentifier(contextObject).hashValue
        return eventName + String(contextObjectHash) + String(Date().timeIntervalSince1970)
    }

    fileprivate func notificationCenter() -> NotificationCenter {
        return NotificationCenter.default
    }

    fileprivate func logIdentifier() -> String {
        if let plugin = self as? Plugin {
            return plugin.pluginName
        }
        return "\(type(of: self))"
    }

    deinit {
        Logger.logDebug("deinit", scope: NSStringFromClass(type(of: self)))
        self.stopListening()
    }
}
