class UIPluginStub: UIPlugin {
    var uiObject: UIObject = UIObject()
    
    static var type: PluginType = .core
    
    static var name: String = "UIPluginStub"
    
    var pluginName: String = "UIPluginStub"
    
    required init() { }
    
    required init(context: UIObject) { }
    
    func destroy() { }
}
