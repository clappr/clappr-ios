import Foundation

public class MediaOption {
    public var name: String
    public var type: MediaOptionType
    public var raw: AnyObject?
    public var language: String
    
    init(name: String, type: MediaOptionType, language: String, raw: AnyObject? = nil) {
        self.name = name
        self.type = type
        self.language = language
        self.raw = raw
    }
}