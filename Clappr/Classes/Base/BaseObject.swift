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

public class BaseObject: NSObject, EventProtocol {
    private var events = [String: Event]()
    private var onceEventsHashes = [String]()
    
    public func on(eventName: String, callback: EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: self)
    }
    
    private func on(eventName: String, callback: EventCallback, contextObject: BaseObject) -> String {
        let listenId = createListenId(eventName, contextObject: contextObject)
        let eventHandler = EventHandler(callback: wrapEventCallback(listenId, callback: callback))
        
        events[listenId] = Event(name: eventName, handler: eventHandler, contextObject: contextObject)
        notificationCenter().addObserver(eventHandler, selector: #selector(EventHandler.handleEvent), name: eventName, object: contextObject)

        return listenId
    }
    
    private func wrapEventCallback(listenId: String, callback: EventCallback) -> EventCallback {
        return { userInfo in
            callback(userInfo: userInfo)
            self.removeListenerIfOnce(listenId, callback: callback)
        }
    }
    
    private func removeListenerIfOnce(listenId: String, callback: EventCallback) {
        if let index = self.onceEventsHashes.indexOf(listenId) {
            onceEventsHashes.removeAtIndex(index)
            off(listenId)
        }
    }
    
    public func once(eventName: String, callback: EventCallback) -> String {
        return once(eventName, callback: callback, contextObject: self)
    }

    private func once(eventName: String, callback: EventCallback, contextObject: BaseObject) -> String {
        let listenId = on(eventName, callback: callback, contextObject: contextObject)
        onceEventsHashes.append(listenId)
        return listenId
    }
    
    public func off(listenId: String) {
        guard let event = events[listenId] else {
            Logger.logError("could not find any event with given event listenId", scope: logIdentifier())
            return
        }
        
        notificationCenter().removeObserver(event.eventHandler, name: event.name, object: event.contextObject)
        events.removeValueForKey(listenId)
    }
    
    public func trigger(eventName: String) {
        trigger(eventName, userInfo: [:])
    }
    
    public func trigger(eventName: String, userInfo: [NSObject : AnyObject]?) {
        notificationCenter().postNotificationName(eventName, object: self, userInfo: userInfo)
        
        if self.dynamicType != BaseObject.self {
            Logger.logDebug("[\(eventName)] triggered with \(userInfo)", scope: logIdentifier())
        }
    }
    
    public func listenTo<T : EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }

    public func listenToOnce<T : EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) -> String {
        return once(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }
    
    public func stopListening() {
        for (_, event) in events {
            notificationCenter().removeObserver(event.eventHandler)
        }
        
        events.removeAll()
    }
    
    public func stopListening(listenId: String) {
        off(listenId)
    }
    
    public func getEventContextObject() -> BaseObject {
        return self
    }
    
    private func createListenId(eventName: String, contextObject: BaseObject) -> String {
        let contextObjectHash = ObjectIdentifier(contextObject).hashValue
        return eventName + String(contextObjectHash) + String(NSDate().timeIntervalSince1970)
    }
    
    private func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }

    private func logIdentifier() -> String {
        if let plugin = self as? Plugin {
            return plugin.pluginName
        }
        return "\(self.dynamicType)"
    }
    
    deinit {
        self.stopListening()
    }
}
