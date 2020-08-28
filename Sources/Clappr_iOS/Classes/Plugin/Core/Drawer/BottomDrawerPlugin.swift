open class BottomDrawerPlugin: DrawerPlugin {
    private var initialCenterY: CGFloat = .zero

    private var maxHeight: CGFloat {
        return overlayViewFrame.height/2
    }

    private var minHeightToShow: CGFloat {
        return overlayViewFrame.height * 0.25
    }

    open var height: CGFloat {
        return maxHeight
    }

    override open var position: DrawerPlugin.Position {
        return .bottom
    }

    private var topDistanceFromBottom: NSLayoutConstraint!

    required public init(context: UIObject) {
        super.init(context: context)

        addGestures()
        initConstraint()
    }

    private func addGestures() {
        addGesture(UITapGestureRecognizer(target: self, action: #selector(didTapView)), cancelingTouchesInView: false)
        addGesture(UIPanGestureRecognizer(target: self, action: #selector(onDragView)))
    }

    private func initConstraint() {
        guard let superview = view.superview else { return }

        topDistanceFromBottom = view.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0)
    }

    override open func render() {
        super.render()

        adjustSize()
        adjustPosition()
    }

    private func adjustSize() {
        view.translatesAutoresizingMaskIntoConstraints = false

        addWidthConstraint()
        addHeightConstraint()
    }

    private func addWidthConstraint() {
        guard let superview = view.superview else { return }

        let widthConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: 0)
        widthConstraint.isActive = true
        superview.addConstraint(widthConstraint)
    }

    private func addHeightConstraint() {
        guard let superview = view.superview else { return }

        if height < maxHeight {
            let heightConstraint = view.heightAnchor.constraint(equalToConstant: height)
            heightConstraint.isActive = true
            view.addConstraint(heightConstraint)
        } else {
            let heightConstraint = view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.5)
            heightConstraint.isActive = true
            superview.addConstraint(heightConstraint)
        }
    }

    private func adjustPosition() {
        guard let superview = view.superview else { return }

        topDistanceFromBottom = view.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: placeholder * -1)
        topDistanceFromBottom.isActive = true

        superview.addConstraint(topDistanceFromBottom)
    }

    override open func onDrawerShow() {
        moveUp()
    }

    override open func onDrawerHide() {
        moveDown()
    }

    private func moveUp(with duration: TimeInterval = ClapprAnimationDuration.mediaControlShow) {
        guard let superview = view.superview else { return }

        topDistanceFromBottom.constant = (overlayViewFrame.height / 2) * -1
        UIView.animate(withDuration: duration) {
            superview.layoutIfNeeded()
        }
    }

    private func moveDown(with duration: TimeInterval = ClapprAnimationDuration.mediaControlHide) {
        guard let superview = view.superview else { return }

        topDistanceFromBottom.constant = placeholder * -1
        UIView.animate(withDuration: duration) {
            superview.layoutIfNeeded()
        }
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

        let translation = gesture.translation(in: view)
        let newBottomDistance = topDistanceFromBottom.constant + translation.y

        if canDrag(with: newBottomDistance) {
            topDistanceFromBottom.constant = newBottomDistance

            let maxOpacity: CGFloat = 1.0
            let distanceFromBottom = abs(newBottomDistance)
            let portionShown = distanceFromBottom / height

            let mediaControlAlpha = maxOpacity - portionShown
            core?.trigger(InternalEvent.didDragDrawer.rawValue, userInfo: ["alpha": mediaControlAlpha])
        }
    }

    private func handleGestureEnded(for newYCoordinate: CGFloat) {
        let isHalfWayOpen = abs(newYCoordinate - overlayViewFrame.height) >= minHeightToShow
        isHalfWayOpen ? showDrawerPlugin() : hideDrawerPlugin()
    }

    private func canDrag(with newBottomDistance: CGFloat) -> Bool {
        let canDragUp = abs(newBottomDistance) < maxHeight
        let canDragDown = abs(newBottomDistance) >= placeholder

        return canDragUp && canDragDown
    }
}
