extension UIView {
    func addSubviewMatchingConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addMatchingConstraints(view)
    }
    
    func addMatchingConstraints(view: UIView) {
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : view]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : view]))
    }
}