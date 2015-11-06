import Foundation

public class BaseObject: NSObject, EventProtocol {
    private var eventHandlers = [String: EventHandler]()
    private var onceEventsHashes = [String]()
    
    public func on(eventName: String, callback: EventCallback) {
        on(eventName, callback: callback, contextObject: self)
    }
    
    private func on(eventName: String, callback: EventCallback, contextObject: BaseObject) {
        let eventHandler = EventHandler(callback: wrapEventCallback(eventName, callback: callback))
        
        notificationCenter().addObserver(eventHandler, selector: "handleEvent:", name: eventName, object: contextObject)
        
        let key = keyForEvent(eventName, contextObject: contextObject, callback: callback)
        eventHandlers[key] = eventHandler
    }
    
    private func wrapEventCallback(eventName: String, callback: EventCallback) -> EventCallback {
        return { userInfo in
            callback(userInfo: userInfo)
            self.removeListenerIfOnce(eventName, callback: callback)
        }
    }
    
    private func removeListenerIfOnce(eventName: String, callback: EventCallback) {
        if let index = self.onceEventsHashes.indexOf(hashForCallback(callback)) {
            onceEventsHashes.removeAtIndex(index)
            off(eventName, callback: callback)
        }
    }
    
    public func once(eventName: String, callback: EventCallback) {
        onceEventsHashes.append(hashForCallback(callback))
        on(eventName, callback: callback)
    }
    
    public func off(eventName: String, callback: EventCallback) {
        off(eventName, callback: callback, contextObject: self)
    }
    
    private func off(eventName: String, callback: EventCallback, contextObject: BaseObject) {
        let key = keyForEvent(eventName, contextObject: contextObject, callback:callback)
        let eventHandler = eventHandlers[key]!
        
        notificationCenter().removeObserver(eventHandler, name: eventName, object: contextObject)
        eventHandlers.removeValueForKey(key)
    }
    
    public func trigger(eventName: String) {
        trigger(eventName, userInfo: [:])
    }
    
    public func trigger(eventName: String, userInfo: [NSObject : AnyObject]?) {
        notificationCenter().postNotificationName(eventName, object: self, userInfo: userInfo)
    }
    
    public func listenTo(contextObject: BaseObject, eventName: String, callback: EventCallback) {
        on(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }
    
    public func stopListening() {
        for (_, eventHandler) in eventHandlers {
            notificationCenter().removeObserver(eventHandler)
        }
        
        eventHandlers.removeAll()
    }
    
    public func stopListening(contextObject: BaseObject, eventName: String, callback: EventCallback) {
        off(eventName, callback: callback, contextObject: contextObject.getEventContextObject())
    }
    
    public func getEventContextObject() -> BaseObject {
        return self
    }
    
    private func keyForEvent(eventName: String, contextObject: BaseObject, callback: EventCallback) -> String {
        let contextObjectHash = ObjectIdentifier(contextObject).hashValue
        return eventName + String(contextObjectHash) + hashForCallback(callback)
    }
    
    private func hashForCallback<A,R>(f:A -> R) -> String {
        let (_, lo) = unsafeBitCast(f, (Int, Int).self)
        let offset = sizeof(Int) == 8 ? 16 : 12
        let ptr  = UnsafePointer<Int>(bitPattern: lo+offset)
        
        return String(ptr.memory) + String(ptr.successor().memory)
    }
    
    private func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    deinit {
        self.stopListening()
    }
}