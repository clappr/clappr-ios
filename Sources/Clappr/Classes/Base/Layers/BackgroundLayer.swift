import UIKit

final class BackgroundLayer: UIView, Layer {
    init() {
        super.init(frame: .zero)

        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
