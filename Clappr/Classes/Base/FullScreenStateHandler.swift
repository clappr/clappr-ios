protocol FullscreenStateHandler {

    var core: Core? { get }
    var isOnFullscreen: Bool { get }

    init(core: Core)

    func enterInFullscreen(_: EventUserInfo)
    func enterInFullscreen()

    func exitFullscreen(_: EventUserInfo)
    func exitFullscreen()
}

extension FullscreenStateHandler {

    func enterInFullscreen() {
        enterInFullscreen([:])
    }

    func exitFullscreen() {
        exitFullscreen([:])
    }

    var isOnFullscreen: Bool {
        return core?.isFullscreen ?? false
    }
}

class FullscreenByApp: FullscreenStateHandler {

    weak var core: Core?

    required init(core: Core) {
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo = [:]) {
        guard !isOnFullscreen else { return }
        core?.trigger(Event.requestFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo = [:]) {
        guard isOnFullscreen else { return }
        core?.trigger(Event.exitFullscreen.rawValue)
    }
}

class FullscreenByPlayer: FullscreenStateHandler {

    weak var core: Core?

    required init(core: Core) {
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo = [:]) {
        guard let core = core, !isOnFullscreen else { return }
        core.trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
        core.fullscreenController.view.backgroundColor = UIColor.black
        core.fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(core.fullscreenController, animated: false, completion: nil)
        core.fullscreenController.view.addSubviewMatchingConstraints(core)
        core.trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo = [:]) {
        guard let core = core, isOnFullscreen else { return }
        core.trigger(InternalEvent.willExitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController.dismiss(animated: false, completion: nil)
        core.trigger(InternalEvent.didExitFullscreen.rawValue)
    }
}
