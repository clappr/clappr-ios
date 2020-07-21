import UIKit

final class BackgroundLayer: UIView {
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attach(to view: UIView) {
        view.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
