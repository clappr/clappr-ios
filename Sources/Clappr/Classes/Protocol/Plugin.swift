public protocol Plugin: EventProtocol {
    static var type: PluginType { get }
    static var name: String { get }
    init()
    init(context: UIObject)
    func destroy()
}

public func theType<T>(of value: T) -> Plugin.Type? {
    return type(of: value) as? Plugin.Type
}

extension Plugin {

    public var pluginName: String {
        guard let selfType = theType(of: self) else { return "" }
        return selfType.name
    }
}
