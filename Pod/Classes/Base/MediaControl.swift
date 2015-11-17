import Foundation

public class MediaControl: UIBaseObject {
    @IBOutlet weak var controlsOverlayView: GradientView!
    @IBOutlet weak var controlsWrapperView: UIView!
    @IBOutlet weak var seekBarView: UIView!
    @IBOutlet weak var bufferBarView: UIView!
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var scrubberView: ScrubberView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var scrubberLabel: UILabel!
    
    @IBAction func togglePlay(sender: UIButton) {
    }
}