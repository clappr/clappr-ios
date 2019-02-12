extension Core {
    
    func addTapGestures() {
        #if os(iOS)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self

        view.addGestureRecognizer(tapRecognizer)
        #endif
    }
    
    @objc func didTap() {
        trigger(InternalEvent.didTappedCore.rawValue)
    }
}
