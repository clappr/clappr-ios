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
    }

    func listenToPlayerEvents() {
        player.on(Event.playing) { _ in print("on Play") }

        player.on(Event.didPause) { _ in print("on Pause") }

        player.on(Event.didStop) { _ in print("on Stop") }

        player.on(Event.didComplete) { _ in print("on Complete") }

        player.on(Event.ready) { _ in print("on Ready") }

        player.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player.on(Event.stalled) { _ in print("on Stalled") }

        player.on(Event.requestFullscreen) { _ in
            self.showAlert(with: "Fullscreen", message: "Entrar em modo fullscreen")
            self.player.setFullscreen(true)
        }

        player.on(Event.exitFullscreen) { _ in
            self.showAlert(with: "Fullscreen", message: "Sair do modo fullscreen")
            self.player.setFullscreen(false)
        }
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

    func showAlert(with title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
        self.navigationController?.present(alertViewController, animated: true, completion: nil)
    }
}
