protocol UIPlugin: Plugin {
    var uiObject: UIObject { get }
    func render()
}
