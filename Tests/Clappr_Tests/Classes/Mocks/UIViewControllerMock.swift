import Foundation
import UIKit

class UIViewControllerMock: UIViewController {
    override var navigationController: UINavigationController? {
        return _navigationController
    }
    
    let _navigationController = UINavigationControllerMock()
}
