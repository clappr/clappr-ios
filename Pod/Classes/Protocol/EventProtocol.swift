public protocol EventProtocol {
    func on(eventName:String, callback: EventCallback) -> String
    func once(eventName:String, callback: EventCallback)
    func off(eventKey: String)
    
    func trigger(eventName:String)
    func trigger(eventName:String, userInfo: [NSObject : AnyObject]?)
    
    func listenTo<T: EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) -> String
    func stopListening()
    func stopListening(eventKey: String)
    
    func getEventContextObject() -> BaseObject
}