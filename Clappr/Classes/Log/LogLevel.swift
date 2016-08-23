public enum LogLevel: Int {
    case Off = 0, Error, Warning, Info, Debug
    
    func description() -> String {
        switch self {
        case .Debug:
            return "DEBUG"
        case .Info:
            return "INFO"
        case .Warning:
            return "WARNING"
        case .Error:
            return "ERROR"
        default:
            return ""
        }
    }
}