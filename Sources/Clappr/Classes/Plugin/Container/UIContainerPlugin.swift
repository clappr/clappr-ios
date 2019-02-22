open class UIContainerPlugin: ContainerPlugin, UIPlugin {
    var uiObject = UIObject()
    
    var view: UIView = UIView()
    
    open func render() {
        uiObject.render()
    }
}
