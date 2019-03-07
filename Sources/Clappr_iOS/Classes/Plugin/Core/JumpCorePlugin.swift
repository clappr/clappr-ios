import UIKit

public class JumpCorePlugin: JumpPlugin {
    
    override open var pluginName: String {
        return "JumpCorePlugin"
    }
    
    override func removeJumpGesture() {
        core?.view.removeGestureRecognizer(jumpGesture)
    }
    
    override func addJumpGesture() {
        jumpGesture = UITapGestureRecognizer(target: self, action: #selector(jump))
        jumpGesture.numberOfTapsRequired = 2
        
        if let coreGesture = core?.view.gestureRecognizers?.first as? UITapGestureRecognizer {
            coreGesture.require(toFail: jumpGesture)
            core?.view.addGestureRecognizer(jumpGesture)
        }
    }
    
    override func shouldSeek(point: CGPoint) -> Bool {
        let pluginColidingWithGesture = core?.activeContainer?.plugins.first(where: {
            !$0.view.isHidden && $0.view.point(inside: core!.view.convert(point, to: $0.view), with: nil)
        })
        return pluginColidingWithGesture == nil
    }
    
    @objc private func jump(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if shouldSeek(point: gestureRecognizer.location(in: view)) {
                let xPosition = gestureRecognizer.location(in: view).x
                jumpSeek(xPosition: xPosition)
            }
        }
    }
}
