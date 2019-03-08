import UIKit

public class JumpPlugin: UICorePlugin {
    
    var doubleTapGesture: UITapGestureRecognizer!
    
    override open var pluginName: String {
        return "JumpPlugin"
    }
    
    private var activePlayback: Playback? {
        return core?.activePlayback
    }
    
    private var animatonHandler: JumpAnimation?
    
    required init(context: UIObject) {
        super.init(context: context)
        animatonHandler = JumpAnimation(core)
        bindEvents()
    }
    
    required init() {
        super.init()
    }
  
    private func bindEvents() {
        stopListening()
        bindCoreEvents()
    }
    
    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, eventName: Event.didChangeActiveContainer.rawValue) { [weak self] _ in self?.bindEvents() }
        listenTo(core, eventName: Event.didShowModal.rawValue) { [weak self] _ in self?.removeGesture() }
        listenTo(core, eventName: Event.didHideModal.rawValue) { [weak self] _ in self?.addGesture() }
    }
    
    func removeGesture() {
        NSException(name: NSExceptionName(rawValue: "MissingPluginImplementation"), reason: "JumpPlugin should implement removeJumpGesture method", userInfo: nil).raise()
    }
    
    func addGesture() {
        NSException(name: NSExceptionName(rawValue: "MissingPluginImplementation"), reason: "JumpPlugin should implement addJumpGesture method", userInfo: nil).raise()
    }
    
    override public func render() {
        addGesture()
    }
    
    func shouldSeek(point: CGPoint) -> Bool {
        return true
    }

    @objc func jumpSeek(xPosition: CGFloat) {
        guard let activePlayback = core?.activePlayback,
            let coreViewWidth = core?.view.frame.width else { return }
        
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
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
}
