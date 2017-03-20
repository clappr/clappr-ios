public enum LogLevel: Int {
    case off = 0, error, warning, info, debug
    
    func description() -> String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        default:
            return ""
        }
    }
}
