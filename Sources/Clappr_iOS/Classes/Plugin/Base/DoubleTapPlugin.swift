import UIKit

public class DoubleTapPlugin: UICorePlugin {
    
    override open var pluginName: String {
        return String(describing: DoubleTapPlugin.self)
    }
    
    private var activePlayback: Playback? {
        return core?.activePlayback
    }
    
    private var animatonHandler: DoubleTapAnimation?
    
    required init(context: UIObject) {
        super.init(context: context)
        animatonHandler = DoubleTapAnimation(core)
    }
    
    required init() {
        super.init()
    }

    @objc func doubleTapSeek(xPosition: CGFloat) {
        guard let position = activePlayback?.position,
            let coreViewWidth = core?.view.frame.width else { return }
        
        impactFeedback()
        if xPosition < coreViewWidth / 2 {
            activePlayback?.seek(position - 10)
            animatonHandler?.animateBackward()
        } else {
            activePlayback?.seek(position + 10)
            animatonHandler?.animateForward()
        }
    }
    
    private func impactFeedback() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
}
