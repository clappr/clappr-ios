class OverlayPlugin: UICorePlugin {
    open class override var name: String {
        return "OverlayPlugin"
    }

    open var isModal: Bool {
        return false
    }

    override func bindEvents() { }
}
