//
//  ScrubberView.swift
//  Pods
//
//  Created by Bruno Torres on 6/3/16.
//
//

import UIKit

public class DragDetectorView: UIView {

    public enum State {
        case Began, Moved, Ended, Canceled, Idle
    }

    public private(set) var touchState: State = .Idle

    public private(set) var currentTouch: UITouch?

    public var target: AnyObject?

    public var selector: Selector!

    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(touches)
        if let touch = touches.first {
            touchState = .Began
            currentTouch = touch
            target?.performSelector(selector, withObject: self)
        }
    }

    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            touchState = .Moved
            currentTouch = touch
            target?.performSelector(selector, withObject: self)
        }
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            touchState = .Ended
            currentTouch = touch
            target?.performSelector(selector, withObject: self)
        }
    }

    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let touch = touches?.first {
            touchState = .Canceled
            currentTouch = touch
            target?.performSelector(selector, withObject: self)
        }
    }
}
