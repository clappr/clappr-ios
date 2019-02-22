open class UICorePlugin: CorePlugin, UIPlugin {
    var uiObject = UIObject()
    
    func render() {
        uiObject.render()
    }
}
