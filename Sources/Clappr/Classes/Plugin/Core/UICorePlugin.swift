open class UICorePlugin: CorePlugin, UIPlugin {
    var uiObject = UIObject()
    public var view: UIView = UIView()
    
    open func render() {
        uiObject.render()
    }
}
