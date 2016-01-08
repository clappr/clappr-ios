import UIKit

public class GradientView: UIView {
    
    private var gradientLayer: CAGradientLayer!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}