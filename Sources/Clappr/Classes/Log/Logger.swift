import Foundation

open class Logger: NSObject {
    fileprivate static var logLevel = LogLevel.info

    open class func setLevel(_ level: LogLevel) {
        logLevel = level
    }

    fileprivate class func log(_ level: LogLevel, message: String) {
        if level.rawValue <= logLevel.rawValue {
            print("\(level.description()) \(message)")
        }
    }

    fileprivate class func log(_ level: LogLevel, scope: String?, message: String) {
        if let scope = scope {
            log(level, message: "[\(scope)] \(message)")
        } else {
            log(level, message: message)
        }
    }

    @objc open class func logError(_ message: String, scope: String? = nil) {
        log(.error, scope: scope, message: message)
    }

    @objc open class func logWarn(_ message: String, scope: String? = nil) {
        log(.warning, scope: scope, message: message)
    }

    @objc open class func logInfo(_ message: String, scope: String? = nil) {
        log(.info, scope: scope, message: message)
    }

    @objc open class func logDebug(_ message: String, scope: String? = nil) {
        log(.debug, scope: scope, message: message)
    }
}
