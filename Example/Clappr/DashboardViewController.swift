import UIKit
import Clappr

class DashboardViewController: UIViewController {

    @IBOutlet weak var switchFullscreenControledByApp: UISwitch!
    @IBOutlet weak var switchFullscreen: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startVideo(_ sender: Any) {
        performSegue(withIdentifier: "startVideo", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? ViewController
        let options: Options = [
            kSourceUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            kPosterUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
            kFullscreen: switchFullscreen.isOn,
            kFullscreenByApp: switchFullscreenControledByApp.isOn
        ]
        viewController?.options = options
    }
}
