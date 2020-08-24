extension UIView {
    @objc public func addSubviewMatchingConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        constrainSize(toSizeOf: view)
        view.layoutIfNeeded()
    }

    @objc func center(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
   @objc func constrainSize(toSizeOf view: UIView) {
        
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    @objc func constrainBounds(
        to view: UIView,
        withInsets insets: UIEdgeInsets = .zero
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom).isActive = true
    }
    
    func setWidthAndHeight(with size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
    
    class func fromNib<T: UIView>() -> T {
        let nib = UINib(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        return (nib.instantiate(withOwner: nil, options: nil).last as? T)!
    }
    
    func addRoundedBorder(with radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }

    func setVerticalPoint(to point: CGFloat, duration: TimeInterval = 0) {
        UIView.animate(withDuration: duration) {
            self.frame.origin.y = point
        }
    }
}
