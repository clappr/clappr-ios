import UIKit
import Clappr

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let options = [posterUrl: "http://clappr.io/poster.png"]
        let player = Player(source: NSURL(string: "http://clappr.io/highline.mp4")!, options: options)
        player.attachTo(playerContainer, controller: self)
    }
}