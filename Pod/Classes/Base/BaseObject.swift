import Foundation

public class BaseObject: NSObject, EventProtocol {
    
    private var eventHandlers = [String: EventHandler]()
    
    public func on(eventName: String, callback: EventCallback) {
        on(eventName, callback: callback, contextObject: self)
    }
    
    private func on(eventName: String, callback: EventCallback, contextObject: BaseObject) {
        let eventHandler = EventHandler(callback: callback)
        
        notificationCenter().addObserver(eventHandler, selector: "handleEvent:", name: eventName, object: contextObject)
        
        let key = keyForEvent(eventName, contextObject: contextObject)
        eventHandlers[key] = eventHandler
    }
    
    public func once(eventName: String, callback: EventCallback) {
        weak var weakSelf = self
        var blockSelf: EventCallback!
        
        let wrapperCallback: EventCallback = { userInfo in
            callback(userInfo: userInfo)
            weakSelf?.off(eventName, callback: blockSelf)
        }
        
        blockSelf = wrapperCallback
        
        on(eventName, callback: wrapperCallback)
    }
    
    public func off(eventName: String, callback: EventCallback) {
        off(eventName, callback: callback, contextObject: self)
    }
    
    private func off(eventName: String, callback: EventCallback, contextObject: BaseObject) {
        let key = keyForEvent(eventName, contextObject: contextObject)
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
    
    public func startListening(contextObject: BaseObject, eventName: String, callback: EventCallback) {
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
    
    private func keyForEvent(eventName: String, contextObject: BaseObject) -> String {
        let contextObjectHash = ObjectIdentifier(contextObject).hashValue
        return eventName + String(contextObjectHash)
    }
    
    private func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    deinit {
        self.stopListening()
    }
}