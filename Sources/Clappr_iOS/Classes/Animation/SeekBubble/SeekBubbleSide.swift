import UIKit

enum SeekBubbleSide {
    case left
    case right
    
    func position() -> NSLayoutConstraint.Attribute {
        switch self {
        case .left: return .leading
        case .right: return .trailing
        }
    }
    
    func positionConstant() -> CGFloat {
        switch self {
        case .left: return 0.5
        case .right: return 1.5
        }
    }
    
    func image() -> UIImageView {
        switch self {
        case .left: return mirrorImage(UIImageView(image: UIImage.fromName("play", for: PlayButton.self)))
        case .right: return UIImageView(image: UIImage.fromName("play", for: PlayButton.self))
        }
    }
    
    private func mirrorImage(_ view: UIImageView) -> UIImageView {
        view.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
        return view
    }
}
