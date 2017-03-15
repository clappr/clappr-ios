import UIKit

open class GradientView: UIView {
    
    fileprivate var gradientLayer: CAGradientLayer!
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
