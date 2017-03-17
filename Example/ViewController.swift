import UIKit
import Clappr

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let options = [kSourceUrl : "http://clappr.io/highline.mp4", kPosterUrl : "http://clappr.io/poster.png"]
        player = Player(options: options as Options)
        
        listenToPlayerEvents()
        
        player.attachTo(playerContainer, controller: self)
    }
    
    func listenToPlayerEvents() {
        _ = player.on(PlayerEvent.play) { _ in
            print("on Play")
        }
        
        _ = player.on(PlayerEvent.pause) { _ in
            print("on Pause")
        }
        
        _ = player.on(PlayerEvent.stop) { _ in
            print("on Stop")
        }
        
        _ = player.on(PlayerEvent.ended) { _ in
            print("on Ended")
        }
        
        _ = player.on(PlayerEvent.ready) { _ in
            print("on Ready")
        }
        
        _ = player.on(PlayerEvent.error) { userInfo in
            print("on Error: \(userInfo)")
        }

        _ = player.on(PlayerEvent.enterFullscreen) { _ in
            print("on Enter Fullscreen")
        }

        _ = player.on(PlayerEvent.exitFullscreen) { _ in
            print("on Exit Fullscreen")
        }
    }

  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.portrait
  }

  override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
    return UIInterfaceOrientation.portrait
  }
}
