class BottomDrawerPlugin: DrawerPlugin {
    override var position: DrawerPlugin.Position {
        return .bottom
    }

    override var size: CGSize {
        return CGSize(width: coreViewBounds.width, height: coreViewBounds.height/2)
    }

    private var coreViewBounds: CGRect {
        guard let core = core else { return .zero }
        return core.view.frame
    }

    private var minYToShow: CGFloat {
        return coreViewBounds.height * 0.75
    }

    private var hiddenHeight: CGFloat {
        return coreViewBounds.height - placeholder
    }

    private var initialCenterY: CGFloat = .zero

    required init(context: UIObject) {
        super.init(context: context)

        addTapGesture()
        addDragGesture()
    }

    override func render() {
        super.render()

        adjustSize()
        moveDown()
        adjustInitialPosition()
    }

    override func onDrawerShow() {
        moveUp()
    }

    override func onDrawerHide() {
        moveDown()
    }

    private func adjustSize() {
        view.frame.size = size
    }

    private func adjustInitialPosition() {
        initialCenterY = view.center.y
    }

    private func moveUp() {
        view.setVerticalPoint(to: size.height, duration: ClapprAnimationDuration.mediaControlShow)
    }

    private func moveDown() {
        view.setVerticalPoint(to: hiddenHeight, duration: ClapprAnimationDuration.mediaControlHide)
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
        guard let gestureView = gesture.view else { return }

        let translation = gesture.translation(in: gestureView)
        let newYCoordinate = gestureView.center.y + translation.y
        let updatedY = gestureView.frame.origin.y

        switch gesture.state {
        case .began, .changed:
            handleGestureChange(for: newYCoordinate, within: gestureView)
        case .ended, .failed:
            handleGestureEnded(for: updatedY)
        default:
            Logger.logInfo("unhandled gesture state")
        }

        gesture.setTranslation(.zero, in: view)
    }

    private func handleGestureChange(for newYCoordinate: CGFloat, within view: UIView) {
        if canDrag(with: newYCoordinate) {
            view.center.y = newYCoordinate
            view.alpha = 1
            let portionShown = initialCenterY - newYCoordinate
            let alpha = hiddenHeight / portionShown * 0.08
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
