import UIKit

open class DragDetectorView: UIView {

    public enum State {
        case began, moved, ended, canceled, idle
    }

    open fileprivate(set) var touchState: State = .idle

    open fileprivate(set) var currentTouch: UITouch?

    open var target: AnyObject?

    open var selector: Selector!

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchState = .began
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchState = .moved
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchState = .ended
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchState = .canceled
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }
}
