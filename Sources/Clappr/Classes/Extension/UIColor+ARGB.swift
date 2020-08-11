import UIKit

extension UIColor {
    var argb: [CGFloat] {
        let color = CIColor(color: self)
        return [ color.alpha, color.red, color.green, color.blue ]
    }
}
