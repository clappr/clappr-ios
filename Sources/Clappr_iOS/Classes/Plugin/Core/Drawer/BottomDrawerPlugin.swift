open class BottomDrawerPlugin: DrawerPlugin {
    private var maxHeight: CGFloat {
        return overlayViewFrame.height/2
    }

    open var height: CGFloat {
        return maxHeight
    }

    override open var position: DrawerPlugin.Position {
        return .bottom
    }
    
    private var closedYPosition: CGFloat {
        return placeholder * -1
    }
    
    private var openedYPosition: CGFloat {
        return min(height, maxHeight) * -1
    }

    private var topDistanceFromBottom: NSLayoutConstraint!
    private var maxHeightConstraint: NSLayoutConstraint!
    private var specifiedHeightConstraint: NSLayoutConstraint!

    required public init(context: UIObject) {
        super.init(context: context)

        addGestures()
        initConstraint()
        bindEvents()
    }
    
    open override func bindEvents() {
        super.bindEvents()
        guard let core = core else { return }
        
        listenTo(core, eventName: Event.didChangeScreenOrientation.rawValue) { [weak self] _ in
            self?.hideDrawerPlugin()
            self?.adjustHeightConstraint()
        }
    }

    private func addGestures() {
        addGesture(UITapGestureRecognizer(target: self, action: #selector(didTapView)), cancelingTouchesInView: false)
        addGesture(UIPanGestureRecognizer(target: self, action: #selector(onDragView)))
    }

    private func initConstraint() {
        guard let superview = view.superview else { return }

        topDistanceFromBottom = view.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0)
        specifiedHeightConstraint = view.heightAnchor.constraint(equalToConstant: height)
        maxHeightConstraint = view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.5)
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
        adjustHeightConstraint()
    }

    private func addWidthConstraint() {
        guard let superview = view.superview else { return }

        let widthConstraint = view.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: 0)
        widthConstraint.isActive = true
    }

    private func addHeightConstraint() {
        guard let superview = view.superview else { return }
        specifiedHeightConstraint = view.heightAnchor.constraint(equalToConstant: height)
        maxHeightConstraint = view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.5)
    }
    
    private func adjustHeightConstraint() {
        if height < maxHeight {
            maxHeightConstraint.isActive = false
            specifiedHeightConstraint.isActive = true
        } else {
            specifiedHeightConstraint.isActive = false
            maxHeightConstraint.isActive = true
        }
    }

    private func adjustPosition() {
        guard let superview = view.superview else { return }

        topDistanceFromBottom = view.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: placeholder * -1)
        topDistanceFromBottom.isActive = true
    }

    override open func onDrawerShow() {
        moveUp()
    }

    override open func onDrawerHide() {
        moveDown()
    }

    private func moveUp(with duration: TimeInterval = ClapprAnimationDuration.mediaControlShow) {
        toggleContentInteraction(enabled: true)
        topDistanceFromBottom.constant = openedYPosition
        refreshSuperviewLayout(with: duration)
    }

    private func moveDown(with duration: TimeInterval = ClapprAnimationDuration.mediaControlHide) {
        toggleContentInteraction(enabled: false)
        topDistanceFromBottom.constant = closedYPosition
        refreshSuperviewLayout(with: duration)
    }

    private func refreshSuperviewLayout(with duration: TimeInterval) {
        guard let superview = view.superview else { return }
        
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
        let halfway = overlayViewFrame.height - ((min(height, maxHeight) + placeholder) * 0.5)
        let isHalfwayOpen = newYCoordinate <= halfway
        
        isHalfwayOpen ? showDrawerPlugin() : hideDrawerPlugin()
    }

    private func canDrag(with newBottomDistance: CGFloat) -> Bool {
        let canDragUp = abs(newBottomDistance) < min(height, maxHeight)
        let canDragDown = abs(newBottomDistance) >= placeholder

        return canDragUp && canDragDown
    }
}

