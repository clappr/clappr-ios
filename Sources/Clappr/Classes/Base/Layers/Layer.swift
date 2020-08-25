import UIKit

protocol Layer: UIView {
    func attach(to view: UIView, at index: Int?)
}

extension Layer {
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
    }
}
