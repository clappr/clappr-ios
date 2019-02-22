import UIKit

public class DoubleTapPlugin: UICorePlugin {
    
    var doubleTapGesture: UITapGestureRecognizer!
    
    override open var pluginName: String {
        return "DoubleTapPlugin"
    }
    
    private var activePlayback: Playback? {
        return core?.activePlayback
    }
    
    private var animatonHandler: DoubleTapAnimation?
    
    required init(context: UIObject) {
        super.init(context: context)
        animatonHandler = DoubleTapAnimation(core)
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
        listenTo(core, eventName: Event.didShowModal.rawValue) { [weak self] _ in self?.removeDoubleTapGesture() }
        listenTo(core, eventName: Event.didHideModal.rawValue) { [weak self] _ in self?.addDoubleTapGesture() }
    }
    
    func removeDoubleTapGesture() {
        NSException(name: NSExceptionName(rawValue: "MissingPluginImplementation"), reason: "DoubleTapPlugin should implement removeDoubleTapGesture method", userInfo: nil).raise()
    }
    
    func addDoubleTapGesture() {
        NSException(name: NSExceptionName(rawValue: "MissingPluginImplementation"), reason: "DoubleTapPlugin should implement addDoubleTapGesture method", userInfo: nil).raise()
    }
    
    override func render() {
        addDoubleTapGesture()
    }
    
    func shouldSeek(point: CGPoint) -> Bool {
        return true
    }

    @objc func doubleTapSeek(xPosition: CGFloat) {
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
