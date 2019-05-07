class UIPluginStub: BaseObject, UIPlugin {
    
    var uiObject: UIObject = UIObject()
    
    var view: UIView = UIView()
    
    static var type: PluginType = .core
    
    static var name: String = "UIPluginStub"
    
    required override init() { }
    
    required init(context: UIObject) { }
    
    func render() { }
    
    func destroy() { }
}
