import Foundation
import UIKit

class UINavigationControllerMock: UINavigationController {
    override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        return _interactivePopGestureRecognizer
    }
    
    let _interactivePopGestureRecognizer = UIGestureRecognizer()
}
