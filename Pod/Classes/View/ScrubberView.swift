import UIKit

class ScrubberView: UIView {
    @IBOutlet var outerCircle: UIView!
    @IBOutlet var innerCircle: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupScrubber()
    }
    
    func setupScrubber() {
        outerCircle.layer.cornerRadius = CGRectGetWidth(outerCircle.frame) / 2
        innerCircle.layer.cornerRadius = CGRectGetWidth(innerCircle.frame) / 2
        outerCircle.layer.borderColor = UIColor(white: 0.75, alpha: 1.0).CGColor
    }
}