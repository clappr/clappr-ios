import UIKit

public class DoubleTapCorePlugin: DoubleTapPlugin {
    
    override open var pluginName: String {
        return "DoubleTapCorePlugin"
    }
    
    override func removeDoubleTapGesture() {
        core?.view.removeGestureRecognizer(doubleTapGesture)
    }
    
    override func addDoubleTapGesture() {
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        
        if let coreGesture = core?.view.gestureRecognizers?.first as? UITapGestureRecognizer {
            coreGesture.require(toFail: doubleTapGesture)
            core?.view.addGestureRecognizer(doubleTapGesture)
        }
    }
    
    override func shouldSeek(point: CGPoint) -> Bool {
        let pluginColidingWithGesture = core?.activeContainer?.plugins.first(where: {
            !$0.view.isHidden && $0.view.point(inside: core!.view.convert(point, to: $0.view), with: nil)
        })
        return pluginColidingWithGesture == nil
    }
    
    @objc private func doubleTap(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if shouldSeek(point: gestureRecognizer.location(in: view)) {
                let xPosition = gestureRecognizer.location(in: view).x
                doubleTapSeek(xPosition: xPosition)
            }
        }
    }
}
