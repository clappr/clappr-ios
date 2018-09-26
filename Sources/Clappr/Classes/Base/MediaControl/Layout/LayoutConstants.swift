import Foundation

enum LayoutConstantType {
    case size, insets
}

struct LayoutConstants {

    static var bottomRight: [LayoutConstantType: Any] = [
        .size: CGSize(width: 38, height: 38),
        .insets: UIEdgeInsets(top: 2, left: 7, bottom: 12, right: 7)
    ]
}
