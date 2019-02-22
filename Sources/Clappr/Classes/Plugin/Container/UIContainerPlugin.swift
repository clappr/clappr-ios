open class UIContainerPlugin: ContainerPlugin, UIPlugin {
    var uiObject = UIObject()
    
    func render() {
        uiObject.render()
    }
}
