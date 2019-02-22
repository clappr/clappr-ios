protocol UIPlugin: Plugin {
    var uiObject: UIObject { get }
    var view: UIView { get set }
    func render()
}

extension UIPlugin {
    func render() {
        uiObject.render()
    }
    
    var view: UIView {
        return uiObject.view
    }
}
