import Foundation

private struct Event {
    var eventHandler: EventHandler
    var contextObject: BaseObject
    var name: String
    
    init(name: String, handler: EventHandler, contextObject: BaseObject) {
        self.name = name
        self.eventHandler = handler
        self.contextObject = contextObject
    }
}

open class BaseObject: NSObject, EventProtocol {
    fileprivate var events = [String: Event]()
    fileprivate var onceEventsHashes = [String]()
    
    open func on(_ eventName: String, callback: @escaping EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: self)
    }
    
    fileprivate func on(_ eventName: String, callback: @escaping EventCallback, contextObject: BaseObject) -> String {
        let listenId = createListenId(eventName, contextObject: contextObject)
        let eventHandler = EventHandler(callback: wrapEventCallback(listenId, callback: callback))
        
        events[listenId] = Event(name: eventName, handler: eventHandler, contextObject: contextObject)
        notificationCenter().addObserver(eventHandler, selector: #selector(EventHandler.handleEvent), name: NSNotification.Name(rawValue: eventName), object: contextObject)

        return listenId
    }
    
    fileprivate func wrapEventCallback(_ listenId: String, callback: @escaping EventCallback) -> EventCallback {
        return { userInfo in
            callback(userInfo)
            self.removeListenerIfOnce(listenId, callback: callback)
        }
    }
    
    fileprivate func removeListenerIfOnce(_ listenId: String, callback: EventCallback) {
        if let index = self.onceEventsHashes.index(of: listenId) {
            onceEventsHashes.remove(at: index)
            off(listenId)
        }
    }
    
    open func once(_ eventName: String, callback: @escaping EventCallback) -> String {
        return once(eventName, callback: callback, contextObject: self)
    }

    fileprivate func once(_ eventName: String, callback: @escaping EventCallback, contextObject: BaseObject) -> String {
        let listenId = on(eventName, callback: callback, contextObject: contextObject)
        onceEventsHashes.append(listenId)
        return listenId
    }
    
    open func off(_ listenId: String) {
        guard let event = events[listenId] else {
            Logger.logError("could not find any event with given event listenId", scope: logIdentifier())
            return
        }
        
        notificationCenter().removeObserver(event.eventHandler, name: NSNotification.Name(rawValue: event.name), object: event.contextObject)
        events.removeValue(forKey: listenId)
    }
    
    open func trigger(_ eventName: String) {
        trigger(eventName, userInfo: [:])
    }
    
    open func trigger(_ eventName: String, userInfo: [AnyHashable: Any]?) {
        notificationCenter().post(name: Notification.Name(rawValue: eventName), object: self, userInfo: userInfo)
        
        if type(of: self) != BaseObject.self {
            Logger.logDebug("[\(eventName)] triggered with \(userInfo)", scope: logIdentifier())
        }
    }
    
    open func listenTo<T : EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }

    open func listenToOnce<T : EventProtocol>(_ contextObject: T, eventName: String, callback: @escaping EventCallback) -> String {
        return once(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }
    
    open func stopListening() {
        for (_, event) in events {
            notificationCenter().removeObserver(event.eventHandler)
        }
        
        events.removeAll()
    }
    
    open func stopListening(_ listenId: String) {
        off(listenId)
    }
    
    open func getEventContextObject() -> BaseObject {
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
        self.stopListening()
    }
}
