public extension UIView {
    @objc public func addSubviewMatchingConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addMatchingConstraints(view)
    }

    @objc func addMatchingConstraints(_ view: UIView) {
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
    }

    @objc func anchorInCenter() {
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false

            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
        }
    }
    
    func bindFrameToSuperviewBounds(marginTop: Double = 0,
                                    marginRight: Double = 0,
                                    marginBottom: Double = 0,
                                    marginLeft: Double = 0,
                                    identifier: String? = nil) {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(marginLeft)-[subview]-\(marginRight)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self])
        
        if let identifier = identifier {
            for constraint in hConstraints {
                constraint.identifier = "H:|-\(marginLeft)-\(identifier)-\(marginRight)-|"
            }
        }
        
        superview.addConstraints(hConstraints)
        
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(marginTop)-[subview]-\(marginBottom)-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self])
        
        if let identifier = identifier {
            for constraint in vConstraints {
                constraint.identifier = "V:|-\(marginTop)-\(identifier)-\(marginBottom)-|"
            }
        }
        
        superview.addConstraints(vConstraints)
    }
    
    func bindFrameToSuperviewBounds(with edges: UIEdgeInsets, identifier: String? = nil) {
        bindFrameToSuperviewBounds(
            marginTop: Double(edges.top),
            marginRight: Double(edges.right),
            marginBottom: Double(edges.bottom),
            marginLeft: Double(edges.left),
            identifier: identifier)
    }
    
    class func fromNib<T: UIView>() -> T {
        let nib = UINib(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        return (nib.instantiate(withOwner: nil, options: nil).last as? T)!
    }
}
