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
        player.on(PlayerEvent.play) { _ in
            print("on Play")
        }
        
        player.on(PlayerEvent.pause) { _ in
            print("on Pause")
        }
        
        player.on(PlayerEvent.stop) { _ in
            print("on Stop")
        }
        
        player.on(PlayerEvent.ended) { _ in
            print("on Ended")
        }
        
        player.on(PlayerEvent.ready) { _ in
            print("on Ready")
        }
        
        player.on(PlayerEvent.error) { userInfo in
            print("on Error: \(userInfo)")
        }

        player.on(PlayerEvent.enterFullscreen) { _ in
            print("on Enter Fullscreen")
        }

        player.on(PlayerEvent.exitFullscreen) { _ in
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
