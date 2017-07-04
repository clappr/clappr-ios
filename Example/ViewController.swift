import UIKit
import Clappr
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    var player: Player!
    let avPlayerViewController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let options = [
            kSourceUrl: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
            kPosterUrl: "http://clappr.io/poster.png",
            kAutoPlay: true
            ] as [String : Any]
        player = Player(options: options)

        listenToPlayerEvents()

        player.attachTo(playerContainer, controller: self)

        addChildViewController(avPlayerViewController)
        avPlayerViewController.view.frame = playerContainer.bounds
        avPlayerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerContainer.addSubview(avPlayerViewController.view)
    }

    func onReady() {
        print("on Ready")

        let pb = player.activePlayback as? AVFoundationPlayback
        avPlayerViewController.player = pb?.player
    }

    func listenToPlayerEvents() {
        player.on(Event.playing) { _ in print("on Play") }

        player.on(Event.didPause) { _ in print("on Pause") }

        player.on(Event.didStop) { _ in print("on Stop") }

        player.on(Event.didComplete) { _ in print("on Complete") }

        player.on(Event.ready) { _ in  self.onReady() }

        player.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player.on(Event.requestFullscreen) { _ in print("on Enter Fullscreen") }

        player.on(Event.exitFullscreen) { _ in print("on Exit Fullscreen") }

        player.on(Event.stalled) { _ in print("on Stalled") }

    }

    #if !os(tvOS)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { // swiftlint:disable:this variable_name
        return UIInterfaceOrientation.portrait
    }
    #endif
}
