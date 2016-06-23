public class Player: BaseObject {
    public private(set) var core: Core
    
    public init(options: Options = [:], externalPlugins: [Plugin.Type] = []) {
        let loader = Loader(externalPlugins: externalPlugins, options: options)
        self.core = CoreFactory.create(loader , options: options)
    }
    
    public func attachTo(view: UIView, controller: UIViewController) {
        bindEvents()
        core.parentController = controller
        core.parentView = view
        core.render()
    }
    
    public func load(source: String, mimeType: String? = nil) {
        core.container.load(source, mimeType: mimeType)
        play()
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
    
    public func seek(timeInterval: NSTimeInterval) {
        core.container.seek(timeInterval)
    }
    
    public func setFullscreen(fullscreen: Bool) {
        core.setFullscreen(fullscreen)
    }
    
    public func on(event: ClapprEvent, callback: EventCallback) -> String {
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
    
    private func forward(event: ClapprEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
    
    deinit {
        stopListening()
    }
}