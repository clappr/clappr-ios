import UIKit
import Clappr

class ViewController: UIViewController {

    var fullscreenController = UIViewController()
    @IBOutlet weak var playerContainer: UIView!
    var player: Player!
    var options: Options = [:]

    var fullscreenByApp: Bool {
        return options[kFullscreenByApp] as? Bool ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        options[kAutoPlay] = true
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

        player.on(Event.willSeek) { _ in print("on willSeek") }

        player.on(Event.seek) { _ in print("on seek") }

        player.on(Event.didSeek) { _ in print("on didSeek") }

        player.on(Event.requestFullscreen) { _ in
            Logger.logInfo("Entrar em modo fullscreen")
            self.onRequestFullscreen()
        }

        player.on(Event.exitFullscreen) { _ in
            Logger.logInfo("Sair do modo fullscreen")
            self.onExitFullscreen()
        }
    }

    func onRequestFullscreen() {
        guard fullscreenByApp else { return }
        fullscreenController.modalPresentationStyle = .overFullScreen
        present(fullscreenController, animated: false) {
            self.player.setFullscreen(true)
        }
        fullscreenController.view.addSubviewMatchingConstraints(player.core!)
    }

    func onExitFullscreen() {
        guard let core = player.core, fullscreenByApp else { return }
        fullscreenController.dismiss(animated: false) {
            self.player.setFullscreen(false)
        }
        core.parentView?.addSubviewMatchingConstraints(core)
    }

    override func viewWillDisappear(_ animated: Bool) {
        player.destroy()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    func showAlert(with title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
        self.navigationController?.present(alertViewController, animated: true, completion: nil)
    }
}
