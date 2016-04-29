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
    
    public func play() {
        core.container.play()
    }
    
    public func pause() {
        core.container.pause()
    }
    
    public func stop() {
        core.container.stop()
    }
    
    public func on(event: PlayerEvent, callback: EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }
    
    private func bindEvents() {
        for (event, callback) in containerBindings() {
            listenTo(core.container, eventName: event.rawValue, callback: callback)
        }
    }
    
    private func containerBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play  : { [weak self] (info: EventUserInfo) in self?.forward(.Play, userInfo: info)},
            .Ready : { [weak self] (info: EventUserInfo) in self?.forward(.Ready, userInfo: info)},
            .Ended : { [weak self] (info: EventUserInfo) in self?.forward(.Ended, userInfo: info)},
            .Error : { [weak self] (info: EventUserInfo) in self?.forward(.Error, userInfo: info)},
            .Stop  : { [weak self] (info: EventUserInfo) in self?.forward(.Stop, userInfo: info)},
            .Pause : { [weak self] (info: EventUserInfo) in self?.forward(.Pause, userInfo: info)}
        ]
    }
    
    private func forward(event: PlayerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
    
    deinit {
        stopListening()
    }
}