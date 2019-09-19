open class BottomDrawerPlugin: DrawerPlugin {
    private var initialCenterY: CGFloat = .zero

    override open var position: DrawerPlugin.Position {
        return .bottom
    }

    override open var size: CGSize {
        return CGSize(width: coreViewFrame.width, height: coreViewFrame.height/2)
    }

    private var minYToShow: CGFloat {
        return coreViewFrame.height * 0.75
    }

    private var hiddenHeight: CGFloat {
        return coreViewFrame.height - placeholder
    }

    required public init(context: UIObject) {
        super.init(context: context)

        addTapGesture()
        addDragGesture()
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
        view.setVerticalPoint(to: size.height, duration: ClapprAnimationDuration.mediaControlShow)
    }

    private func moveDown(with duration: TimeInterval = ClapprAnimationDuration.mediaControlHide) {
        view.setVerticalPoint(to: hiddenHeight, duration: duration)
    }

    private func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)
    }

    private func addDragGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onDragView))
        view.addGestureRecognizer(gesture)
    }

    @objc private func didTapView() {
        showDrawerPlugin()
        hideMediaControl()
    }

    private func showDrawerPlugin() {
        core?.trigger(.showDrawerPlugin)
    }

    private func hideMediaControl() {
        activeContainer?.trigger(.disableMediaControl)
    }

    private func hideDrawerPlugin() {
        core?.trigger(.hideDrawerPlugin)
        activeContainer?.trigger(.enableMediaControl)
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
            let alpha = hiddenHeight / portionShown * 0.08

            view.center.y = gesture.newYCoordinate
            view.alpha = 1

            core?.trigger(.didDragDrawer, userInfo: ["alpha": alpha])
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
