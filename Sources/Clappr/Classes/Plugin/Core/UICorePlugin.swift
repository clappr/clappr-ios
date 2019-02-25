open class UICorePlugin: CorePlugin, UIPlugin {
    var uiObject = UIObject()
    
    public var view: UIView {
        return uiObject.view
    }
    
    open func render() {
        NSException(name: NSExceptionName("RenderNotOverriden"), reason: "UICorePlugins should always override the render method").raise()
    }
}
