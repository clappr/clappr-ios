import UIKit

extension UIImage {
    func isEqualTo(image: UIImage) -> Bool {
        let data1: Data = UIImagePNGRepresentation(self)!
        let data2: Data = UIImagePNGRepresentation(image)!
        return data1 == data2
    }
}
