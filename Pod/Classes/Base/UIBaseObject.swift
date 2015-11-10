import Foundation

public class UIBaseObject: UIView, EventProtocol {
    private let baseObject = BaseObject()
    
    public func on(eventName:String, callback: EventCallback) {
        baseObject.on(eventName, callback: callback)
    }
    
    public func once(eventName:String, callback: EventCallback) {
        baseObject.once(eventName, callback: callback)
    }
    
    public func off(eventName:String, callback: EventCallback) {
        baseObject.off(eventName, callback: callback)
    }
    
    public func trigger(eventName:String) {
        baseObject.trigger(eventName)
    }
    
    public func trigger(eventName:String, userInfo: [NSObject : AnyObject]?) {
        baseObject.trigger(eventName, userInfo: userInfo)
    }
    
    public func listenTo<T: EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) {
        baseObject.listenTo(contextObject, eventName: eventName, callback: callback)
    }
    
    public func stopListening() {
        baseObject.stopListening()
    }
    
    public func stopListening<T : EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) {
        baseObject.stopListening(contextObject, eventName: eventName, callback: callback)
    }
    
    public func getEventContextObject() -> BaseObject {
        return baseObject
    }
}