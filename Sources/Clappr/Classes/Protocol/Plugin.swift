public protocol Plugin: EventProtocol {
    static var type: PluginType { get }
    static var name: String { get }
    var pluginName: String { get }
    init()
    init(context: UIObject)
    func destroy()
}

public func theType<T>(of value: T) -> Plugin.Type? {
    return type(of: value) as? Plugin.Type
}
