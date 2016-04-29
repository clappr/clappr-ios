public class Player: BaseObject {
    public private(set) var core: Core
    
    public init(options: Options = [:], externalPlugins: [Plugin.Type] = []) {
        let loader = Loader(externalPlugins: externalPlugins, options: options)
        self.core = CoreFactory.create(loader , options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        bindEvents()
        view.addSubviewMatchingConstraints(core)
        core.render()
        core.parentController = controller
    }
    
    private func bindEvents() {
        listenTo(core.container, eventName: ContainerEvent.Play.rawValue, callback: onPlay)
    }
    
    private func onPlay(userInfo: EventUserInfo) {
        trigger(PlayerEvent.Play.rawValue, userInfo: userInfo)
    }
    
    public func on(event: PlayerEvent, callback: EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }
    
    deinit {
        stopListening()
    }
}