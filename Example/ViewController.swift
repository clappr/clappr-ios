import UIKit
import Clappr

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    var player: Player!
    var options: Options = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        player = Player(options: options)

        listenToPlayerEvents()

        player.attachTo(playerContainer, controller: self)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func rotated() {
        if UIDevice.current.orientation.isLandscape {
            player.setScreen(state: .fullscreen)
        } else {
            player.setScreen(state: .embed)
        }
    }

    func listenToPlayerEvents() {
        player.on(Event.playing) { _ in print("on Play") }

        player.on(Event.didPause) { _ in print("on Pause") }

        player.on(Event.didStop) { _ in print("on Stop") }

        player.on(Event.didComplete) { _ in print("on Complete") }

        player.on(Event.ready) { _ in print("on Ready") }

        player.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player.on(Event.requestFullscreen) { _ in print("on Enter Fullscreen") }

        player.on(Event.exitFullscreen) { _ in print("on Exit Fullscreen") }

        player.on(Event.stalled) { _ in print("on Stalled") }

    }

    override func viewWillDisappear(_ animated: Bool) {
        player.destroy()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { // swiftlint:disable:this variable_name
        return UIInterfaceOrientation.portrait
    }
}
