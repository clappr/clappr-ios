import Foundation

public class MediaOption {
    public var name: String
    public var type: MediaOptionType
    public var raw: AnyObject?
    
    init(name: String, type: MediaOptionType, raw: AnyObject? = nil) {
        self.name = name
        self.type = type
        self.raw = raw
    }
}