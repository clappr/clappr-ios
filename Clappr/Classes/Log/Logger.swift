import Foundation

public class Logger {
    private static var logLevel = LogLevel.Info

    public class func setLevel(level: LogLevel) {
        logLevel = level
    }

    private class func log(level: LogLevel, message: String) {
        if level.rawValue <= logLevel.rawValue {
            print("\(level.description()) \(message)")
        }
    }

    private class func log(level: LogLevel, scope: String?, message: String) {
        if let scope = scope {
            log(level, message: "[\(scope)] \(message)")
        } else {
            log(level, message: message)
        }
    }

    public class func logError(message: String, scope: String? = nil) {
        log(.Error, scope: scope, message: message)
    }

    public class func logWarn(message: String, scope: String? = nil) {
        log(.Warning, scope: scope, message: message)
    }

    public class func logInfo(message: String, scope: String? = nil) {
        log(.Info, scope: scope, message: message)
    }

    public class func logDebug(message: String, scope: String? = nil) {
        log(.Debug, scope: scope, message: message)
    }
}