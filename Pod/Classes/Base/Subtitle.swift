import Foundation

public class Subtitle {
    public var name: String?
    public var raw: AnyObject?
    
    init(name: String, raw: AnyObject) {
        self.name = name
        self.raw = raw
    }
}