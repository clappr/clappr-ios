open class UIContainerPlugin: ContainerPlugin, UIPlugin {
    var uiObject = UIObject()
    
    public var view: UIView {
        return uiObject.view
    }
    
    open func render() {
        uiObject.render()
    }
}
