import UIKit

public class QuickSeekPlugin: UICorePlugin {
    
    var doubleTapGesture: UITapGestureRecognizer!

    open class override var name: String {
        return "QuickSeekPlugin"
    }
    
    private var activePlayback: Playback? {
        return core?.activePlayback
    }
    
    private var animatonHandler: QuickSeekAnimation?
    
    required init(context: UIObject) {
        super.init(context: context)
        animatonHandler = QuickSeekAnimation(core)
    }
    
    override public func bindEvents() {
        bindCoreEvents()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, eventName: Event.didShowModal.rawValue) { [weak self] _ in self?.removeGesture() }
        listenTo(core, eventName: Event.didHideModal.rawValue) { [weak self] _ in self?.addGesture() }
    }
    
    func removeGesture() {
        NSException(name: NSExceptionName(rawValue: "MissingPluginImplementation"), reason: "QuickSeekPlugin should implement removeGesture method", userInfo: nil).raise()
    }
    
    func addGesture() {
        NSException(name: NSExceptionName(rawValue: "MissingPluginImplementation"), reason: "QuickSeekPlugin should implement addGesture method", userInfo: nil).raise()
    }
    
    override public func render() {
        addGesture()
    }
    
    func shouldSeek(point: CGPoint) -> Bool {
        return true
    }

    @objc func quickSeek(xPosition: CGFloat) {
        guard let activePlayback = core?.activePlayback,
            let container = core?.activeContainer,
            let coreViewWidth = core?.view.frame.width else { return }
        
        container.trigger(InternalEvent.didTapQuickSeek.rawValue)
        let didTapLeftSide = xPosition < coreViewWidth / 2
        if didTapLeftSide {
            seekBackward(activePlayback)
        } else {
            seekForward(activePlayback)
        }
    }
    
    private func seekBackward(_ playback: Playback) {
        guard playback.playbackType == .vod || playback.isDvrAvailable else { return }
        impactFeedback()
        playback.seek(playback.position - 10)
        guard playback.position - 10 > 0.0 else { return }
        animatonHandler?.animateBackward()
    }
    
    private func seekForward(_ playback: Playback) {
        guard playback.playbackType == .vod || playback.isDvrAvailable && playback.isDvrInUse else { return }
        impactFeedback()
        playback.seek(playback.position + 10)
        guard playback.position + 10 < playback.duration else { return }
        animatonHandler?.animateForward()
    }
    
    private func impactFeedback() {
        UIImpactFeedbackGenerator().impactOccurred()
    }
}
