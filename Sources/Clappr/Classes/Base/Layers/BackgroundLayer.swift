import UIKit

final class BackgroundLayer: Layer {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
