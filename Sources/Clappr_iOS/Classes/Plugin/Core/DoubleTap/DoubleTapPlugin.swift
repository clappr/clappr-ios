import UIKit

public class DoubleTapPlugin: UICorePlugin {
    
    override open var pluginName: String {
        return String(describing: DoubleTapPlugin.self)
    }
    
    var doubleTapView = PassthroughView()
    
    private var activePlayback: Playback? {
        return core?.activePlayback
    }
    
    private var activeContainer: Container? {
        return core?.activeContainer
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
        listenTo(core, eventName: Event.didShowModal.rawValue) { [weak self] _ in
            self?.doubleTapView.isUserInteractionEnabled = false
        }
        listenTo(core, eventName: Event.didHideModal.rawValue) { [weak self] _ in
            self?.doubleTapView.isUserInteractionEnabled = true
        }
    }
    
    override public func render() {
        doubleTapView.core = core
        doubleTapView.backgroundColor = .clear
        core?.view.addSubview(doubleTapView)
        doubleTapView.bindFrameToSuperviewBounds()
        addGestures()
    }
    
    private func addGestures() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        tapGesture.require(toFail: doubleTapGesture)
        
        doubleTapView.addGestureRecognizer(doubleTapGesture)
        doubleTapView.addGestureRecognizer(tapGesture)
    }

    @objc private func doubleTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            let xPosition = gestureRecognizer.location(in: view).x
            doubleTapSeek(xPosition: xPosition)
        }
    }
    
    @objc private func singleTap(gestureRecognizer: UITapGestureRecognizer) {
        toggleMediaControl()
    }
    
    private func toggleMediaControl() {
        core?.trigger(InternalEvent.didTappedCore.rawValue)
    }
    
    @objc func doubleTapSeek(xPosition: CGFloat) {
        guard let position = activePlayback?.position,
            let coreViewWidth = core?.view.frame.width,
            let mediaControl = core?.plugins.first(where: { $0 is MediaControl }) else { return }
        
        if !mediaControl.view.isHidden {
            toggleMediaControl()
        }
        
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
