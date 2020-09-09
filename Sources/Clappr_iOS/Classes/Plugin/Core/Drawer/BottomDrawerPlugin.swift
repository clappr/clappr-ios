open class BottomDrawerPlugin: DrawerPlugin {
    private var maxHeight: CGFloat {
        overlayViewFrame.height/2
    }

    open var desiredHeight: CGFloat {
        maxHeight
    }

    override open var position: DrawerPlugin.Position {
        .bottom
    }
    
    private var hintPosition: CGFloat {
        placeholder * -1
    }

    private var actualHeight: CGFloat {
        min(desiredHeight, maxHeight)
    }
    
    private var openedYPosition: CGFloat {
        actualHeight * -1
    }

    private var drawerTopConstraint: NSLayoutConstraint!
    private var maxHeightConstraint: NSLayoutConstraint!
    private var desiredHeightConstraint: NSLayoutConstraint!

    required public init(context: UIObject) {
        super.init(context: context)
        addGestures()
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

    override open func render() {
        super.render()
        setupConstraints()
    }

    private func setupConstraints() {
        view.translatesAutoresizingMaskIntoConstraints = false
        guard let superview = view.superview else { return }
        view.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: 0).isActive = true

        drawerTopConstraint = view.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: hintPosition)
        drawerTopConstraint.isActive = true

        desiredHeightConstraint = view.heightAnchor.constraint(equalToConstant: desiredHeight)
        maxHeightConstraint = view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.5)

        adjustHeightConstraint()
    }

    private func adjustHeightConstraint() {
        if desiredHeight < maxHeight {
            maxHeightConstraint.isActive = false
            desiredHeightConstraint.isActive = true
        } else {
            desiredHeightConstraint.isActive = false
            maxHeightConstraint.isActive = true
        }
    }

    override open func onDrawerShow() {
        moveUp()
    }

    override open func onDrawerHide() {
        moveDown()
    }

    private func moveUp(with duration: TimeInterval = ClapprAnimationDuration.mediaControlShow) {
        toggleContentInteraction(enabled: true)
        drawerTopConstraint.constant = openedYPosition
        refreshSuperviewLayout(with: duration)
    }

    private func moveDown(with duration: TimeInterval = ClapprAnimationDuration.mediaControlHide) {
        toggleContentInteraction(enabled: false)
        drawerTopConstraint.constant = hintPosition
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
        let newBottomDistance = drawerTopConstraint.constant + translation.y

        if canDrag(with: newBottomDistance) {
            drawerTopConstraint.constant = newBottomDistance

            calculateMediaControlAlpha(for: newBottomDistance)
        }
    }

    private func calculateMediaControlAlpha(for newBottomDistance: CGFloat) {
        let maxOpacity: CGFloat = 1.0
        let distanceFromBottom = abs(newBottomDistance)
        let portionShown = distanceFromBottom / actualHeight
        let mediaControlAlpha = maxOpacity - portionShown

        core?.trigger(InternalEvent.didDragDrawer.rawValue, userInfo: ["alpha": mediaControlAlpha])
    }

    private func handleGestureEnded(for newYCoordinate: CGFloat) {
        let halfway = overlayViewFrame.height - ((actualHeight + placeholder) * 0.5)
        let isHalfwayOpen = newYCoordinate <= halfway
        
        isHalfwayOpen ? showDrawerPlugin() : hideDrawerPlugin()
    }

    private func canDrag(with newBottomDistance: CGFloat) -> Bool {
        let canDragUp = abs(newBottomDistance) < actualHeight
        let canDragDown = abs(newBottomDistance) >= placeholder

        return canDragUp && canDragDown
    }
}
