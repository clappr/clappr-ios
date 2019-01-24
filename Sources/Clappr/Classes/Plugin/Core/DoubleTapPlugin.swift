import Foundation

class DoubleTapPlugin: UICorePlugin {
    
    override open var pluginName: String {
        return String(describing: DoubleTapPlugin.self)
    }
    
    private var activePlayback: Playback? {
        return core?.activePlayback
    }
    
    private var activeContainer: Container? {
        return core?.activeContainer
    }
    
    private var animatonHandler: DoubleTapAnimation?
    
    required init(context: UIObject) {
        super.init(context: context)
        bindEvents()
        animatonHandler = DoubleTapAnimation(core)
    }
    
    required init() {
        super.init()
        bindEvents()
    }
    
    private func bindEvents() {
        stopListening()
        bindCoreEvents()
        bindContainerEvents()
    }
    
    private func bindCoreEvents() {
        guard let core = self.core else { return }
        listenTo(core, eventName: Event.didChangeActiveContainer.rawValue) { [weak self] _ in self?.bindEvents() }
        listenTo(core, eventName: InternalEvent.didDoubleTappedCore.rawValue) { [weak self] userInfo in self?.doubleTapSeek(userInfo) }
    }
    
    private func bindContainerEvents() {
        if let container = activeContainer {
            listenTo(container,
                     eventName: Event.didChangePlayback.rawValue) { [weak self] (_: EventUserInfo) in self?.bindEvents() }
        }
    }
    
    private func doubleTapSeek(_ userInfo: EventUserInfo) {
        guard let position = activePlayback?.position,
            let xPosition = userInfo?["viewLocation"] as? CGFloat,
            let coreViewWidth = core?.view.frame.width else { return }
        
        let viewCenterPosition = coreViewWidth / 2
        impactFeedback()
        if xPosition < viewCenterPosition {
            activePlayback?.seek(position - 10)
            animatonHandler?.animateBackward()
        } else {
            activePlayback?.seek(position + 10)
            animatonHandler?.animateForward()
        }
    }
    
    private func impactFeedback() {
        if #available(iOS 10.0, *) {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
        }
    }
}
