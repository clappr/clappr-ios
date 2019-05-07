public protocol Plugin: EventProtocol, NamedType {
    static var type: PluginType { get }
    init(context: UIObject)
    func destroy()
}

public protocol NamedType {
    static var name: String { get }
}

extension NamedType {
    public var pluginName: String {
        return type(of: self).name
    }
}
