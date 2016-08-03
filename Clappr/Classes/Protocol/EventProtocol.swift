public protocol EventProtocol {
    func on(eventName:String, callback: EventCallback) -> String
    func once(eventName:String, callback: EventCallback) -> String
    func off(listenId: String)
    
    func trigger(eventName:String)
    func trigger(eventName:String, userInfo: [NSObject : AnyObject]?)
    
    func listenTo<T: EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) -> String
    func listenToOnce<T: EventProtocol>(contextObject: T, eventName: String, callback: EventCallback) -> String
    func stopListening()
    func stopListening(listenId: String)
    
    func getEventContextObject() -> BaseObject
}