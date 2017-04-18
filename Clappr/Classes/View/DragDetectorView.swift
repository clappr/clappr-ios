import UIKit

open class DragDetectorView: UIView {

    public enum State {
        case began, moved, ended, canceled, idle
    }

    fileprivate(set) open var touchState: State = .idle

    fileprivate(set) open var currentTouch: UITouch?

    open var target: AnyObject?

    open var selector: Selector!

    open override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first {
            touchState = .began
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first {
            touchState = .moved
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first {
            touchState = .ended
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
        if let touch = touches.first {
            touchState = .canceled
            currentTouch = touch
            _ = target?.perform(selector, with: self)
        }
    }
}
