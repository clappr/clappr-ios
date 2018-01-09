import UIKit

class FullscreenController: UIViewController {

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ? UIInterfaceOrientation.landscapeLeft : UIInterfaceOrientation.landscapeRight
    }
}
