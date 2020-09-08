open class DrawerPlugin: OverlayPlugin {
    public enum Position {
        case undefined
        case bottom
    }

    open var position: DrawerPlugin.Position {
        return .undefined
    }

    var size: CGSize {
        return .zero
    }

    open var placeholder: CGFloat {
        return .zero
    }

    open var overlayViewFrame: CGRect {
        guard let overlayView = view.superview else { return .zero }
        return overlayView.frame
    }

    private(set) var isClosed: Bool = true {
        willSet {
            let event: Event = newValue ? .willHideDrawerPlugin : .willShowDrawerPlugin
            core?.trigger(event)
        }
        didSet {
            if isClosed {
                hide()
                core?.trigger(.didHideDrawerPlugin)
            } else {
                show()
                core?.trigger(.didShowDrawerPlugin)
            }
        }
    }

    public required init(context: UIObject) {
        super.init(context: context)
        view.alpha = .zero
    }

    open override func bindEvents() {
        guard let core = core else { return }

        bindCoreEvents(context: core)
        bindMediaControlEvents(context: core)
        bindDrawerEvents(context: core)
    }

    private func bindCoreEvents(context: UIObject) {
        listenTo(context, eventName: InternalEvent.didTappedCore.rawValue) { [weak self] _ in
            guard self?.isClosed == false else { return }

            context.trigger(.hideDrawerPlugin)
        }
    }

    private func bindMediaControlEvents(context: UIObject) {
        listenTo(context, event: .willShowMediaControl) { [weak self] _ in
            UIView.animate(withDuration: ClapprAnimationDuration.mediaControlShow) {
                self?.view.alpha = 1
            }
        }

        listenTo(context, event: .willHideMediaControl) { [weak self] _ in
            guard self?.isClosed == true else { return }
            UIView.animate(withDuration: ClapprAnimationDuration.mediaControlHide) {
                self?.view.alpha = 0
            }
        }
    }

    private func bindDrawerEvents(context: UIObject) {
        listenTo(context, event: .showDrawerPlugin) { [weak self] _ in
            self?.toggleIsClosed(to: false)
            self?.onDrawerShow()
        }

        listenTo(context, event: .hideDrawerPlugin) { [weak self] _ in
            self?.toggleIsClosed(to: true)
            self?.onDrawerHide()
        }
    }

    private func toggleIsClosed(to newValue: Bool) {
        isClosed = newValue
    }

    override open func render() {
        requestPaddingIfNeeded()
    }

    open func onDrawerShow() {
        Logger.logWarn("You have to override onDrawerShow function")
    }

    open func onDrawerHide() {
        Logger.logWarn("You have to override onDrawerHide function")
    }

    private func requestPaddingIfNeeded() {
        if placeholder > 0 {
            core?.trigger(.requestPadding, userInfo: ["padding": CGFloat(32)])
        }
    }
}
