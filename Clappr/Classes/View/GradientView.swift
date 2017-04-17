import UIKit

open class GradientView: UIView {

    fileprivate var gradientLayer: CAGradientLayer!

    open override func awakeFromNib() {
        super.awakeFromNib()

        gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
