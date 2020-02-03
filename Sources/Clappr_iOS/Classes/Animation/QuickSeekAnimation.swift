class QuickSeekAnimation {
    private var seekLeftBubble = SeekBubble()
    private var seekRightBubble = SeekBubble()
    
    init(_ view: UIView?) {
        guard let parentView = view else { return }
        seekLeftBubble.setup(within: parentView, bubbleSide: .left)
        seekRightBubble.setup(within: parentView, bubbleSide: .right)
    }
    
    func animateBackward() {
        seekLeftBubble.animate()
    }
    
    func animateForward() {
        seekRightBubble.animate()
    }
}
