import Foundation

extension Dictionary where Key == String, Value == Any {
    var startAt: Double? {
        switch self[kStartAt] {
        case is Double:
            return self[kStartAt] as? Double
        case is Int:
            return Double(self[kStartAt] as! Int)
        case is String:
            return Double(self[kStartAt] as! String)
        default:
            return nil
        }
    }
}
