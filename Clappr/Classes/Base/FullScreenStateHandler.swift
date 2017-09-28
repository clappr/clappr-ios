public enum ScreenState {
    case fullscreen, embed
}

protocol FullscreenStateHandler {

    init()

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
}

class FullscreenByApp: BaseObject, FullscreenStateHandler {

    required override init() {
        super.init()
    }

    func enterInFullscreen(_: EventUserInfo = [:]) {
        trigger(Event.requestFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo = [:]) {
        trigger(Event.exitFullscreen.rawValue)
    }
}

class FullscreenByPlayer: BaseObject, FullscreenStateHandler {

    weak var core: Core?

    required override init() {
        super.init()
    }

    convenience init(core: Core) {
        self.init()
        self.core = core
    }

    func enterInFullscreen(_: EventUserInfo = [:]) {
        guard let core = core else { return }
        trigger(InternalEvent.willEnterFullscreen.rawValue)
        core.mediaControl?.fullscreen = true
        core.fullscreenController.view.backgroundColor = UIColor.black
        core.fullscreenController.modalPresentationStyle = .overFullScreen
        core.parentController?.present(core.fullscreenController, animated: false, completion: nil)
        core.fullscreenController.view.addSubviewMatchingConstraints(core)
        trigger(InternalEvent.didEnterFullscreen.rawValue)
    }

    func exitFullscreen(_: EventUserInfo = [:]) {
        guard let core = core else { return }
        trigger(InternalEvent.willExitFullscreen.rawValue)
        core.mediaControl?.fullscreen = false
        core.parentView?.addSubviewMatchingConstraints(core)
        core.fullscreenController.dismiss(animated: false, completion: nil)
        trigger(InternalEvent.didExitFullscreen.rawValue)
    }
}
