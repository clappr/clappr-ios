open class UICorePlugin: SimpleCorePlugin, UIPlugin {
    var uiObject = UIObject()
    
    public var view: UIView {
        get {
            return uiObject.view
        } set(newValue) {
            return uiObject.view = newValue
        }
    }
    
    #if os(tvOS)
    func updateFocus(userInfo: EventUserInfo) {
        core?.trigger(.requestFocusUpdate, userInfo: userInfo)
    }
    
    func updateFocus() {
        core?.trigger(.requestFocusUpdate)
    }
    #endif
    
    open func render() {
        NSException(name: NSExceptionName("RenderNotOverriden"), reason: "UICorePlugins should always override the render method").raise()
    }
}
