import UIKit
import Clappr

class DashboardViewController: UIViewController {

    @IBOutlet weak var switchFullScreen: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startVideo(_ sender: Any) {
        performSegue(withIdentifier: "startVideo", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? ViewController
        let options: Options = [
            kSourceUrl: "http://clappr.io/highline.mp4",
            kPosterUrl: "http://clappr.io/poster.png",
            kFullscreen: true,
            kFullscreenByApp: switchFullScreen.isOn
        ]
        viewController?.options = options
    }
}
