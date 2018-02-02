import UIKit
import Clappr
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    var player: Player!

    override func viewDidLoad() {
        super.viewDidLoad()

        let options = [
            kSourceUrl: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
            kAutoPlay: true,
            kMediaControl: true
            ] as [String: Any]
        player = Player(options: options)

        listenToPlayerEvents()

        addChildViewController(player)
        player.view.frame = view.bounds
        view.addSubview(player.view)
        player.didMove(toParentViewController: self)
    }

    func listenToPlayerEvents() {
        player.on(Event.playing) { _ in print("on Play") }

        player.on(Event.didPause) { _ in print("on Pause") }

        player.on(Event.didStop) { _ in print("on Stop") }

        player.on(Event.didComplete) { _ in print("on Complete") }

        player.on(Event.ready) { _ in  print("on Ready") }

        player.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player.on(Event.stalled) { _ in print("on Stalled") }

        player.on(Event.willSeek) { _ in print("on willSeek") }

        player.on(Event.seek) { _ in print("on seek") }

        player.on(Event.didSeek) { _ in print("on didSeek") }
    }

    #if !os(tvOS)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    #endif
}
