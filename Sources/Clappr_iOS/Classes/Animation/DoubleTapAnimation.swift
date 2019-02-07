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
        guard let playback = core?.activePlayback,
            playback.position - 10 > 0.0 else { return }
        seekLeftBubble.animate()
    }
    
    func animateForward() {
        guard let playback = core?.activePlayback,
            playback.position + 10 < playback.duration else { return }
        seekRightBubble.animate()
    }
}
