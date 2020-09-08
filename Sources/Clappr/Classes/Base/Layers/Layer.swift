import UIKit

open class Layer: UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attach(to view: UIView, at index: Int? = nil) {
        if let index = index {
            view.insertSubview(self, at: index)
        } else {
            view.addSubview(self)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        view.layoutIfNeeded()
    }
}
