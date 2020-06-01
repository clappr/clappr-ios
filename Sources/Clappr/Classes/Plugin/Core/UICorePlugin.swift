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
    open func requestFocusToMe() {
        let info: EventUserInfo = ["viewTag": view.tag]
        core?.trigger(.requestFocus, userInfo: info)
    }
    
    open func updateFocus() {
        core?.trigger(.updateFocus)
    }
    #endif
    
    open func render() {
        NSException(name: NSExceptionName("RenderNotOverriden"), reason: "UICorePlugins should always override the render method").raise()
    }
}
