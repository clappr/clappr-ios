protocol FullscreenStateHandler {
    var core: Core? { get }
    init(core: Core)
    func enterInFullscreen(_: EventUserInfo)
    func exitFullscreen(_: EventUserInfo)
}

struct FullscreenByApp: FullscreenStateHandler {
    weak var core: Core?
    init(core: Core) {
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo) {
        guard let core = core else {
            return
        }
        core.trigger(Event.requestFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
    }

    func exitFullscreen(_: EventUserInfo) {
        guard let core = core else {
            return
        }
        core.trigger(Event.exitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
    }
}

struct FullscreenByPlayer: FullscreenStateHandler {
    weak var core: Core?
    init(core: Core) {
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo) {
        guard let core = core else {
            return
        }
        core.trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
        core.fullscreenController.view.backgroundColor = UIColor.black
        core.fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(core.fullscreenController, animated: false, completion: nil)
        core.fullscreenController.view.addSubviewMatchingConstraints(core)
        core.trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo) {
        guard let core = core else {
            return
        }
        core.trigger(InternalEvent.willExitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController.dismiss(animated: false, completion: nil)
        core.trigger(InternalEvent.didExitFullscreen.rawValue)
    }
}
