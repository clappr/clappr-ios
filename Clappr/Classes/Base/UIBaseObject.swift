open class UIBaseObject: UIView, BaseObject {
    open func render() {}

    deinit {
        Logger.logDebug("deinit", scope: logIdentifier())
    }
}
