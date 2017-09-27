protocol FullscreenStateHandler {
    var core: Core? { get }
    init(core: Core)
    func enterInFullscreen(_: EventUserInfo)
    func exitFullscreen(_: EventUserInfo)
}

class FullscreenByApp: BaseObject, FullscreenStateHandler {
    weak var core: Core?
    required init(core: Core) {
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo) {
        guard let core = core else { return }
        trigger(Event.requestFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
    }

    func exitFullscreen(_: EventUserInfo) {
        guard let core = core else { return }
        trigger(Event.exitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
    }
}

class FullscreenByPlayer: BaseObject, FullscreenStateHandler {
    weak var core: Core?
    required init(core: Core) {
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo) {
        guard let core = core else { return }
        trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
        core.fullscreenController.view.backgroundColor = UIColor.black
        core.fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(core.fullscreenController, animated: false, completion: nil)
        core.fullscreenController.view.addSubviewMatchingConstraints(core)
        trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo) {
        guard let core = core else { return }
        trigger(InternalEvent.willExitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController.dismiss(animated: false, completion: nil)
        trigger(InternalEvent.didExitFullscreen.rawValue)
    }
}
