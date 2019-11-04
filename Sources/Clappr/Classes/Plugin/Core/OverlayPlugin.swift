open class OverlayPlugin: UICorePlugin {
    open class override var name: String {
        return "OverlayPlugin"
    }

    open var isModal: Bool {
        return false
    }

    open func show() {
        core?.trigger(.didShowOverlayPlugin)
    }

    open func hide() {
        core?.trigger(.didHideOverlayPlugin)
    }
}
