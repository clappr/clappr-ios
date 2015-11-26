import UIKit
import Clappr

class ViewController: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let player = Player(source: NSURL(string: "http://clappr.io/highline.mp4")!)
        player.attachTo(playerContainer)
    }
}