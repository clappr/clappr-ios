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
    open func requestFocus() {
        let info: EventUserInfo = ["viewTag": view.tag]
        core?.trigger(.requestFocus, userInfo: info)
    }
    
    open func releaseFocus() {
        let info: EventUserInfo = ["viewTag": view.tag]
        core?.trigger(.releaseFocus, userInfo: info)
    }
    #endif
    
    open func render() {
        NSException(name: NSExceptionName("RenderNotOverriden"), reason: "UICorePlugins should always override the render method").raise()
    }
}
