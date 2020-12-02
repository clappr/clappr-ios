import UIKit

public class QuickSeekCorePlugin: QuickSeekPlugin {
    open class override var name: String {
        return "QuickSeekCorePlugin"
    }
    
    override func removeGesture() {
        guard let doubleTapGesture = doubleTapGesture else { return }

        core?.view.removeGestureRecognizer(doubleTapGesture)
    }
    
    override func addGesture() {
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        doubleTapGesture.numberOfTapsRequired = 2
        
        if let coreGesture = core?.view.gestureRecognizers?.first as? UITapGestureRecognizer {
            coreGesture.require(toFail: doubleTapGesture)
            core?.view.addGestureRecognizer(doubleTapGesture)
        }
    }
    
    override func shouldSeek(point: CGPoint) -> Bool {
        let pluginColidingWithGesture = activeContainer?.plugins
            .compactMap({ $0 as? UIContainerPlugin })
            .first(where: {
            !$0.view.isHidden && $0.view.point(inside: core!.view.convert(point, to: $0.view), with: nil)
        })
        return pluginColidingWithGesture == nil
    }
    
    @objc private func didTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if shouldSeek(point: gestureRecognizer.location(in: view)) {
                let xPosition = gestureRecognizer.location(in: view).x
                quickSeek(xPosition: xPosition)
            }
        }
    }
}
