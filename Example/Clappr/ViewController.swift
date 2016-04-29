import UIKit
import Clappr

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    var player: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let options = [kSourceUrl : "http://clappr.io/highline.mp4", kPosterUrl : "http://clappr.io/poster.png"]
        player = Player(options: options)
        
        listenToPlayerEvents()
        
        player.attachTo(playerContainer, controller: self)
    }
    
    func listenToPlayerEvents() {
        player.on(PlayerEvent.Play) { _ in
            print("on play")
        }
        
        player.on(PlayerEvent.Pause) { _ in
            print("on Pause")
        }
        
        player.on(PlayerEvent.Stop) { _ in
            print("on Stop")
        }
        
        player.on(PlayerEvent.Ended) { _ in
            print("on Ended")
        }
        
        player.on(PlayerEvent.Ready) { _ in
            print("on Ready")
        }
        
        player.on(PlayerEvent.Error) { userInfo in
            print("on Error: \(userInfo)")
        }
    }
}