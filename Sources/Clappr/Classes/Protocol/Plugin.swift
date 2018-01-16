public protocol Plugin {
    static var type: PluginType { get }
    static var name: String { get }
    var pluginName: String { get }
    init()
    init(context: UIBaseObject)
    func destroy()
}
