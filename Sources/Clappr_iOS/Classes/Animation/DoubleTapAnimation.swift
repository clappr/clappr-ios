class DoubleTapAnimation {
    private var core: Core?
    private var seekLeftBubble = SeekBubble()
    private var seekRightBubble = SeekBubble()
    
    init(_ core: Core?) {
        self.core = core
        if let coreView = core?.view {
            seekLeftBubble.setup(within: coreView, bubbleSide: .left)
            seekRightBubble.setup(within: coreView, bubbleSide: .right)
        }
    }
    
    func animateBackward() {
        seekLeftBubble.animate()
    }
    
    func animateForward() {
        seekRightBubble.animate()
    }
}
