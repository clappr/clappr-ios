public protocol Plugin: EventProtocol, Nameable {
    static var type: PluginType { get }
    init(context: UIObject)
    func destroy()
}

public protocol Nameable {
    static var name: String { get }
}

extension Nameable {
    public var pluginName: String {
        return type(of: self).name
    }
}
