open class UIContainerPlugin: ContainerPlugin, UIPlugin {
    var uiObject = UIObject()
    
    public var view: UIView {
        return uiObject.view
    }
    
    open func render() {
        NSException(name: NSExceptionName("RenderNotOverriden"), reason: "UIContainerPlugins should always override the render method").raise()
    }
}
