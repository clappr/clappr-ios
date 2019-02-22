open class UIContainerPlugin: ContainerPlugin, UIPlugin {
    var uiObject = UIObject()
    public var view: UIView = UIView()
    
    open func render() {
        uiObject.render()
    }
}
