import Foundation

open class MediaOption: Equatable {
    open var name: String
    open var type: MediaOptionType
    open var raw: AnyObject?
    open var language: String

    public init(name: String, type: MediaOptionType, language: String, raw: AnyObject? = nil) {
        self.name = name
        self.type = type
        self.language = language
        self.raw = raw
    }

    public static func ==(lhs: MediaOption, rhs: MediaOption) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.language == rhs.language
    }
}
