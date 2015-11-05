public protocol EventProtocol {
    func on(eventName:String, callback: EventCallback)
    func once(eventName:String, callback: EventCallback)
    func off(eventName:String, callback: EventCallback)
    
    func trigger(eventName:String)
    func trigger(eventName:String, userInfo: [NSObject : AnyObject]?)
    
    func startListening(contextObject: BaseObject, eventName: String, callback: EventCallback)
    func stopListening()
    func stopListening(contextObject: BaseObject, eventName: String, callback: EventCallback)
    
    func getEventContextObject() -> BaseObject
}