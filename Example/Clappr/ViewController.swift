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
        player.on(ClapprEvent.Play) { _ in
            print("on Play")
        }
        
        player.on(ClapprEvent.Pause) { _ in
            print("on Pause")
        }
        
        player.on(ClapprEvent.Stop) { _ in
            print("on Stop")
        }
        
        player.on(ClapprEvent.Ended) { _ in
            print("on Ended")
        }
        
        player.on(ClapprEvent.Ready) { _ in
            print("on Ready")
        }
        
        player.on(ClapprEvent.Error) { userInfo in
            print("on Error: \(userInfo)")
        }
    }
}