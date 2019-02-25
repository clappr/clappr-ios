protocol UIPlugin: Plugin {
    var uiObject: UIObject { get }
    func render()
}

extension UIPlugin {
    func render() {
        uiObject.render()
    }
}
