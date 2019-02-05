import UIKit

protocol DoubleTapViewDelegate {
    func shouldIgnoreTap() -> Bool
    func mediaControlPluginsColideWithTouch(point: CGPoint, event: UIEvent?, view: UIView) -> Bool
}

class DoubleTapView: UIView {
    
    var delegate: DoubleTapViewDelegate?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let delegate = delegate else { return false }
        if delegate.shouldIgnoreTap() {
            return false
        }
        return delegate.mediaControlPluginsColideWithTouch(point: point, event: event, view: self)
    }
}
