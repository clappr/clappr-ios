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
        Player.register(plugins: [BrokenPlugin.self])
        player = Player(options: options)

        listenToPlayerEvents()

        player.attachTo(playerContainer, controller: self)
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

        player.on(Event.requestFullscreen) { _ in
            print("on requestFullscreen")
            self.onRequestFullscreen()
        }

        player.on(Event.exitFullscreen) { _ in
            print("on exitFullscreen")
            self.onExitFullscreen()
        }
    }

    @objc func onRequestFullscreen() {
        guard fullscreenByApp else { return }
        fullscreenController.modalPresentationStyle = .overFullScreen
        present(fullscreenController, animated: false) {
            self.player.setFullscreen(true)
        }
        fullscreenController.view.addSubviewMatchingConstraints(player.core!.view)
    }

    @objc func onExitFullscreen() {
        guard let core = player.core, fullscreenByApp else { return }
        fullscreenController.dismiss(animated: false) {
            self.player.setFullscreen(false)
        }
        core.parentView?.addSubviewMatchingConstraints(core.view)
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
        alertViewController.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
        self.navigationController?.present(alertViewController, animated: true, completion: nil)
    }
}

class BrokenPlugin: MediaControlPlugin {
    override var pluginName: String {
        return "broken"
    }

    required public init(context: UIObject) {
        super.init(context: context)
        bindEvents()
    }

    required public init() {
        super.init()
    }

    private func bindEvents() {
        stopListening()

        bindCoreEvents()
    }

    open func bindCoreEvents() {
        if let core = core {
            listenTo(core, eventName: Event.didChangeActiveContainer.rawValue) { [weak self] _ in self?.iWillCrash() }
        }
    }

    override func destroy() {
        iWillCrash()
    }

    override func render() {
        iWillCrash()
    }

    func iWillCrash() {
        let viewCrash = UIView()
        viewCrash.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.addSubview(viewCrash)
    }
}
