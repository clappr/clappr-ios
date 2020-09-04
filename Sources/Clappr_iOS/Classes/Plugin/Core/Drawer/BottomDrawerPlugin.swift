open class BottomDrawerPlugin: DrawerPlugin {
    private var initialCenterY: CGFloat = .zero

    private var maxHeight: CGFloat {
        return coreViewFrame.height/2
    }

    open var height: CGFloat {
        return maxHeight
    }

    override open var position: DrawerPlugin.Position {
        return .bottom
    }

    override var size: CGSize {
        return CGSize(width: coreViewFrame.width, height: min(maxHeight, height))
    }

    private var minYToShow: CGFloat {
        return coreViewFrame.height * 0.75
    }

    private var hiddenHeight: CGFloat {
        return coreViewFrame.height - placeholder
    }

    required public init(context: UIObject) {
        super.init(context: context)

        addGesture(UITapGestureRecognizer(target: self, action: #selector(didTapView)), cancelingTouchesInView: false)
        addGesture(UIPanGestureRecognizer(target: self, action: #selector(onDragView)))
    }

    override open func render() {
        super.render()

        adjustSize()
        moveDown(with: .zero)
        adjustInitialPosition()
    }

    private func adjustSize() {
        view.frame.size = size
    }

    private func adjustInitialPosition() {
        initialCenterY = view.center.y
    }

    override open func onDrawerShow() {
        moveUp()
    }

    override open func onDrawerHide() {
        moveDown()
    }

    private func moveUp() {
        toggleContentInteraction(enabled: true)
        view.setVerticalPoint(to: size.height, duration: ClapprAnimationDuration.mediaControlShow)
    }

    private func moveDown(with duration: TimeInterval = ClapprAnimationDuration.mediaControlHide) {
        toggleContentInteraction(enabled: false)
        view.setVerticalPoint(to: hiddenHeight, duration: duration)
    }

    private func toggleContentInteraction(enabled: Bool) {
        self.view.subviews.first?.isUserInteractionEnabled = enabled
    }

    private func addGesture(_ gesture: UIGestureRecognizer, cancelingTouchesInView: Bool = true) {
        gesture.cancelsTouchesInView = cancelingTouchesInView
        view.addGestureRecognizer(gesture)
    }

    @objc private func didTapView() {
        showDrawerPlugin()
    }

    private func showDrawerPlugin() {
        core?.trigger(.showDrawerPlugin)
    }

    private func hideDrawerPlugin() {
        core?.trigger(.hideDrawerPlugin)
    }

    @objc private func onDragView(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch gesture.state {
        case .began, .changed:
            handleGestureChange(with: gesture)
        case .ended, .failed:
            handleGestureEnded(for: view.frame.origin.y)
        default:
            Logger.logInfo("unhandled gesture state")
        }

        gesture.setTranslation(.zero, in: view)
    }

    private func handleGestureChange(with gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        if canDrag(with: gesture.newYCoordinate) {
            let portionShown = initialCenterY - gesture.newYCoordinate
            let mediaControlAlpha = hiddenHeight / portionShown * 0.08

            view.center.y = gesture.newYCoordinate
            view.alpha = 1

            core?.trigger(InternalEvent.didDragDrawer.rawValue, userInfo: ["alpha": mediaControlAlpha])
        }
    }

    private func handleGestureEnded(for newYCoordinate: CGFloat) {
        let isHalfWayOpen = newYCoordinate <= minYToShow
        isHalfWayOpen ? showDrawerPlugin() : hideDrawerPlugin()
    }

    private func canDrag(with newYCoordinate: CGFloat) -> Bool {
        let canDragUp = newYCoordinate > minYToShow
        let canDragDown = initialCenterY > newYCoordinate
        return canDragUp && canDragDown
    }
}
