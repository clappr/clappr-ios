import UIKit

public class DoubleTapPlugin: UICorePlugin {
    
    var doubleTapGesture: UITapGestureRecognizer!
    
    override open var pluginName: String {
        return String(describing: "DoubleTapPlugin")
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
    
    public override func render() {
        addDoubleTapGesture()
    }

    @objc func doubleTapSeek(xPosition: CGFloat) {
        guard let activePlayback = core?.activePlayback,
            let coreViewWidth = core?.view.frame.width else { return }
        
        let playBackPosition = activePlayback.position
        impactFeedback()
        if xPosition < coreViewWidth / 2 {
            activePlayback.seek(playBackPosition - 10)
            guard playBackPosition - 10 > 0.0 else { return }
            animatonHandler?.animateBackward()
        } else {
            activePlayback.seek(playBackPosition + 10)
            guard playBackPosition + 10 < activePlayback.duration else { return }
            animatonHandler?.animateForward()
        }
    }
    
    private func impactFeedback() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator().impactOccurred()
        }
    }
}
