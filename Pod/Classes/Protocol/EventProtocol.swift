public protocol EventProtocol {
    func on(eventName:String, callback: EventCallback)
    func once(eventName:String, callback: EventCallback)
    func off(eventName:String, callback: EventCallback)
    
    func trigger(eventName:String)
    func trigger(eventName:String, userInfo: [NSObject : AnyObject]?)
    
    func listenTo<T: EventProtocol>(contextObject: T, eventName: String, callback: EventCallback)
    func stopListening()
    func stopListening<T: EventProtocol>(contextObject: T, eventName: String, callback: EventCallback)
    
    func getEventContextObject() -> BaseObject
}