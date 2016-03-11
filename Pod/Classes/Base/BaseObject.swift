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
        let key = keyForEvent(eventName, contextObject: contextObject)
        let eventHandler = EventHandler(callback: wrapEventCallback(key, callback: callback))
        
        events[key] = Event(name: eventName, handler: eventHandler, contextObject: contextObject)
        notificationCenter().addObserver(eventHandler, selector: "handleEvent:", name: eventName, object: contextObject)

        return key
    }
    
    private func wrapEventCallback(eventKey: String, callback: EventCallback) -> EventCallback {
        return { userInfo in
            callback(userInfo: userInfo)
            self.removeListenerIfOnce(eventKey, callback: callback)
        }
    }
    
    private func removeListenerIfOnce(eventKey: String, callback: EventCallback) {
        if let index = self.onceEventsHashes.indexOf(eventKey) {
            onceEventsHashes.removeAtIndex(index)
            off(eventKey)
        }
    }
    
    public func once(eventName: String, callback: EventCallback) {
        onceEventsHashes.append(on(eventName, callback: callback))
    }
    
    public func off(eventKey: String) {
        guard let event = events[eventKey] else {
            print("BaseObject Error: Could not find any event with give event key")
            return
        }
        
        notificationCenter().removeObserver(event.eventHandler, name: event.name, object: event.contextObject)
        events.removeValueForKey(eventKey)
    }
    
    public func trigger(eventName: String) {
        trigger(eventName, userInfo: [:])
    }
    
    public func trigger(eventName: String, userInfo: [NSObject : AnyObject]?) {
        notificationCenter().postNotificationName(eventName, object: self, userInfo: userInfo)
    }
    
    public func listenTo<T : EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) -> String {
        return on(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }
    
    public func stopListening() {
        for (_, event) in events {
            notificationCenter().removeObserver(event.eventHandler)
        }
        
        events.removeAll()
    }
    
    public func stopListening(eventKey: String) {
        off(eventKey)
    }
    
    public func getEventContextObject() -> BaseObject {
        return self
    }
    
    private func keyForEvent(eventName: String, contextObject: BaseObject) -> String {
        let contextObjectHash = ObjectIdentifier(contextObject).hashValue
        return eventName + String(contextObjectHash) + String(NSDate().timeIntervalSince1970)
    }
    
    private func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    deinit {
        self.stopListening()
    }
}