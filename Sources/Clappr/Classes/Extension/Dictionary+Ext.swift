import Foundation

extension Dictionary where Key == String, Value == Any {
    var startAt: Double? { optionAsOptionalDouble(kStartAt) }
    var liveStartTime: Double? { optionAsOptionalDouble(kLiveStartTime) }
    
    private func optionAsOptionalDouble(_ option:String) -> Double? {
        switch self[option] {
        case is Double:
            return self[option] as? Double
        case let option as Int:
            return Double(option)
        case let option as String:
            return Double(option)
        default:
            return nil
        }
    }
}

public extension Dictionary where Key == String, Value == Any {
    func bool(_ option: String, orElse alternative: Bool = false) -> Bool {
        if let value = self[option] as? Bool {
            return value
        }
        return alternative
    }
}
