import UIKit
import Clappr

class ViewController: UIViewController {

    @objc var fullscreenController = UIViewController()
    @IBOutlet weak var playerContainer: UIView!
    @objc var player: Player!
    @objc var options: Options = [:]

    @objc var fullscreenByApp: Bool {
        return options[kFullscreenByApp] as? Bool ?? false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createPlayer()
    }

    @objc func listenToPlayerEvents() {
        player.on(Event.playing) { _ in print("on Play") }

        player.on(Event.didPause) { _ in print("on Pause") }

        player.on(Event.didStop) { _ in print("on Stop") }

        player.on(Event.didComplete) { _ in print("on Complete") }

        player.on(Event.ready) { _ in print("on Ready") }

        player.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player.on(Event.stalling) { _ in print("on Stalling") }

        player.on(Event.willSeek) { _ in print("on willSeek") }

        player.on(Event.didSeek) { _ in print("on didSeek") }
        
        player.on(Event.willShowMediaControl) { _ in print("on willShowMediaControl") }
        
        player.on(Event.didShowMediaControl) { _ in print("on didShowMediaControl") }
        
        player.on(Event.willHideMediaControl) { _ in print("on willHideMediaControl") }
        
        player.on(Event.didHideMediaControl) { _ in print("on didHideMediaControl") }

        player.on(Event.requestFullscreen) { [weak self] _ in
            print("on requestFullscreen")
            self?.onRequestFullscreen()
        }

        player.on(Event.exitFullscreen) { [weak self] _ in
            print("on exitFullscreen")
            self?.onExitFullscreen()
        }
    }

    @objc func onRequestFullscreen() {
        guard fullscreenByApp else { return }
        fullscreenController.modalPresentationStyle = .overFullScreen
        present(fullscreenController, animated: false) {
            self.player.setFullscreen(true)
        }
        player.presentFullscreenIn(fullscreenController)
    }

    @objc func onExitFullscreen() {
        guard fullscreenByApp else { return }
        fullscreenController.dismiss(animated: false) {
            self.player.setFullscreen(false)
        }
        player.fitParentView()
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

    @objc func showAlert(with title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.navigationController?.present(alertViewController, animated: true, completion: nil)
    }
    
    private func createPlayer() {
        player = Player(options: options)

        listenToPlayerEvents()

        player.attachTo(playerContainer, controller: self)
        player.play()
    }
    
    @IBAction func recreatePlayer(_ sender: Any) {
        player.destroy()
        player = nil
        createPlayer()
    }
}
