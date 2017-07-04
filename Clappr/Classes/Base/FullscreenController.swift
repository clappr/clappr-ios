import UIKit

class FullscreenController: UIViewController {

    #if !os(tvOS)
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { // swiftlint:disable:this variable_name
        return UIInterfaceOrientation.landscapeRight
    }
    #endif
}
