import Foundation

public class BaseObject: EventProtocol {
    
    public func on(eventName: String, callback: EventCallback) {
        
    }
    
    public func once(eventName: String, callback: EventCallback) {
        
    }
    
    public func off(eventName: String, callback: EventCallback) {
        
    }
    
    public func trigger(eventName: String) {
        
    }
    
    public func trigger(eventName: String, userInfo: [NSObject : AnyObject]?) {
        
    }
    
    public func startListening(contextObject: EventProtocol, eventName: String, callback: EventCallback) {
        
    }
    
    public func stopListening() {
        
    }
    
    public func stopListening(contextObject: EventProtocol, eventName: String, callback: EventCallback) {
        
    }
    
    public func getEventContextObject() -> BaseObject {
        return self
    }
    
    deinit {
        self.stopListening()
    }
}