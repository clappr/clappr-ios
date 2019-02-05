import UIKit

protocol DoubleTapViewDelegate {
    func shouldIgnoreTap() -> Bool
    func mediaControlPluginsColideWithTouch(point: CGPoint, event: UIEvent?, view: UIView) -> Bool
}

class DoubleTapView: UIView {
    
    var delegate: DoubleTapViewDelegate?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if delegate?.shouldIgnoreTap() ?? true {
            return false
        }
        return delegate?.mediaControlPluginsColideWithTouch(point: point, event: event, view: self) ?? true
    }
}
